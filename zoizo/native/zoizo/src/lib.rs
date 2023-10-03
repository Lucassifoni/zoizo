mod parabola;
use std::fmt::Display;

use std::io::Cursor;
use image::{ImageBuffer, imageops::{crop, resize, dither, BiLevel, ColorMap, grayscale, index_colors}, Luma};
use imageproc::gray_image;
use nokhwa::{
    pixel_format::RgbFormat,
    utils::{CameraIndex, CameraInfo, RequestedFormat, RequestedFormatType},
    Camera, NokhwaError,
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
    match inner_capture() {
        Ok(a) => a,
        _ => ([].to_vec(), [].to_vec())
    }
}

fn inner_capture() -> Result<(Vec<u8>, Vec<u8>), NokhwaError>{
    let index = CameraIndex::Index(0);
    let requested =
        RequestedFormat::new::<RgbFormat>(RequestedFormatType::AbsoluteHighestFrameRate);
    let mut camera = Camera::new(index, requested)?;
    camera.open_stream()?;
    let frame = camera.frame()?;
    let decoded = frame.decode_image::<RgbFormat>()?;
    let mut bytes: Vec<u8> = Vec::new();
    decoded.write_to(&mut Cursor::new(&mut bytes), image::ImageOutputFormat::Jpeg(100)).unwrap();
    Ok((bytes, prepare_for_remote(decoded)))
}

fn prepare_for_remote(mut img: ImageBuffer<image::Rgb<u8>, Vec<u8>>) -> Vec<u8> {
    // Assumption that the image is larger than it is wide.
    let h = img.height();
    let w = img.width();
    let x = (w - h) / 2;
    let mut cropped = crop(&mut img, x, 0, h, h);
    let mut resized = resize(&mut *cropped, 100, 100, image::imageops::FilterType::Nearest);
    let mut gray = grayscale(&mut resized);
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
