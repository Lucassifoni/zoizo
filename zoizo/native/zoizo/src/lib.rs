mod parabola;
use std::fmt::Display;

use std::io::Cursor;
use image::{ImageBuffer, imageops::{crop, resize, dither, BiLevel, ColorMap, grayscale}, Luma};
use imageproc::gray_image;
use nokhwa::{
    pixel_format::RgbFormat,
    utils::{CameraIndex, CameraInfo, RequestedFormat, RequestedFormatType},
    Camera,
};
use parabola::Segment;
use rustler::ResourceArc;

#[rustler::nif]
pub fn non_parallel_rayfan_coords(
    focal_length: f64,
    radius: f64,
    source_distance: f64,
    source_height: f64,
    rays: i32,
) -> Vec<Segment> {
    parabola::non_parallel_rayfan_coords(focal_length, radius, source_distance, source_height, rays)
}


#[rustler::nif(schedule = "DirtyIo")]
pub fn capture() -> (Vec<u8>, Vec<u8>) {
    let index = CameraIndex::Index(0);
    let requested =
        RequestedFormat::new::<RgbFormat>(RequestedFormatType::AbsoluteHighestFrameRate);
    let mut camera = Camera::new(index, requested).unwrap();
    camera.open_stream().unwrap();
    let frame = camera.frame().unwrap();
    let decoded = frame.decode_image::<RgbFormat>().unwrap();
    let mut bytes: Vec<u8> = Vec::new();
    decoded.write_to(&mut Cursor::new(&mut bytes), image::ImageOutputFormat::Jpeg(100)).unwrap();
    (bytes, prepare_for_remote(decoded))
}

pub struct QuadGrey;

impl ColorMap for QuadGrey {
    type Color = Luma<u8>;

    fn index_of(&self, color: &Self::Color) -> usize {
        (color.0[0] / 63).into()
    }

    fn lookup(&self, index: usize) -> Option<Self::Color> {
        match index {
            0 => Some([11].into()),
            1 =>Some([67].into()),
            2 =>Some([136].into()),
            3 => Some([249].into()),
            _ => None
        }
    }

    fn map_color(&self, color: &mut Self::Color) {
        let new_color = 0xFF * self.index_of(color) as u8;
        let luma = &mut color.0;
        luma[0] = new_color;
    }
}

fn prepare_for_remote(mut img: ImageBuffer<image::Rgb<u8>, Vec<u8>>) -> Vec<u8> {
    // Assumption that the image is larger than it is wide.
    let h = img.height();
    let w = img.width();
    let x = (w - h) / 2;
    let mut cropped = crop(&mut img, x, 0, h, h);
    let mut resized = resize(&mut *cropped, 100, 100, image::imageops::FilterType::Nearest);
    let mut gray = grayscale(&mut resized);
    dither(&mut gray, &QuadGrey);
    gray.into_vec()
}

#[rustler::nif]
pub fn reflection_angle(
    focal_length: f64,
    y: f64,
    source_distance: f64,
    source_height: f64,
) -> f64 {
    parabola::reflection_angle(focal_length, y, source_distance, source_height)
}


rustler::init!(
    "Elixir.Zoizo",
    [
        non_parallel_rayfan_coords,
        reflection_angle,
        capture
    ]
);
