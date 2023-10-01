mod parabola;
use std::fmt::Display;

use std::io::Cursor;
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
pub fn capture() -> Vec<u8> {
    let index = CameraIndex::Index(0);
    // request the absolute highest resolution CameraFormat that can be decoded to RGB.
    let requested =
        RequestedFormat::new::<RgbFormat>(RequestedFormatType::AbsoluteHighestFrameRate);
    // make the camera
    let mut camera = Camera::new(index, requested).unwrap();
    camera.open_stream().unwrap();
    // get a frame
    let frame = camera.frame().unwrap();
    // decode into an ImageBuffer
    let decoded = frame.decode_image::<RgbFormat>().unwrap();
    let mut bytes: Vec<u8> = Vec::new();
    decoded.write_to(&mut Cursor::new(&mut bytes), image::ImageOutputFormat::Jpeg(94)).unwrap();
    bytes
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
