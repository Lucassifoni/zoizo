use std::fmt::Display;

use image::{
    imageops::{crop, dither, grayscale, index_colors, resize, BiLevel, ColorMap},
    ImageBuffer, Luma, load_from_memory, DynamicImage, ImageError, flat::Error,
};
use imageproc::gray_image;
use rustler::ResourceArc;
use std::io::Cursor;
use std::process::Stdio;


#[rustler::nif]
pub fn capture(img: rustler::Binary) -> (Vec<u8>, Vec<u8>) {
    match inner_capture(img.to_vec()) {
        Ok(a) => a,
        _ => ([].to_vec(), [].to_vec()),
    }
}

struct CaptureError {}
impl From<std::io::Error> for CaptureError {
    fn from(err: std::io::Error) -> CaptureError {
        CaptureError{}
    }
}

impl From<ImageError> for CaptureError {
    fn from(err: ImageError) -> CaptureError {
        CaptureError{}
    }
}


fn inner_capture(img: Vec<u8>) -> Result<(Vec<u8>, Vec<u8>), CaptureError> {
    let mut image = load_from_memory(&img).unwrap();
    Ok((img, prepare_for_remote(image.to_rgb8())))
}

fn prepare_for_remote(mut img: ImageBuffer<image::Rgb<u8>, Vec<u8>>) -> Vec<u8> {
    // Assumption that the image is larger than it is wide.
    let h = img.height();
    let w = img.width();
    let x = (w - h) / 2;
    let mut cropped = crop(&mut img, x, 0, h, h);
    let mut resized = resize(
        &mut *cropped,
        100,
        100,
        image::imageops::FilterType::Nearest,
    );
    let gray = grayscale(&mut resized);
    gray.into_vec()
}

fn load(env: rustler::Env, _info: rustler::Term) -> bool {
    true
}

rustler::init!("Elixir.Scope.Capture", [capture], load = load);
