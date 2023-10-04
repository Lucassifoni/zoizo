use std::fmt::Display;

use std::io::Cursor;
use image::{ImageBuffer, imageops::{crop, resize, dither, BiLevel, ColorMap, grayscale, index_colors}, Luma};
use imageproc::gray_image;
use nokhwa::{
    pixel_format::RgbFormat,
    utils::{CameraIndex, CameraInfo, RequestedFormat, RequestedFormatType},
    Camera, NokhwaError,
};
use rustler::ResourceArc;

#[rustler::nif]
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
    let gray = grayscale(&mut resized);
    gray.into_vec()
}

fn load(env: rustler::Env, _info: rustler::Term) -> bool {
    true
}

rustler::init!(
    "Elixir.Scope.Capture",
    [
        capture
    ],
    load = load
);
