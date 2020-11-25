import pyrealsense2 as rs
import cv2
import numpy as np
import os
import glob
import sys
import time
import shutil
import tempfile
import threading
import string
import winsound
import ctypes
import argparse
from pathlib import Path



# Create librealsense context for managing devices
ctx = rs.context()
colorizer = rs.colorizer()
preset = 0
presets = [4, 8, 9, 0]

## get Screen Size
user32 = ctypes.windll.user32
screensize = user32.GetSystemMetrics(0), user32.GetSystemMetrics(1)

#
args = 0


CAPTURES_DIR = ''
CALIBRATION_DIR = ''

NUMBER_OF_CAPTURES = 0
TIME_FOR_TIMER = 0
NUMBER_OF_PICTURES_FOR_CALIBRATION = 0
TIME_TO_SHOW_IMAGES = 0


CALIBRATE_CAMERAS = False
CAPTURE = False
PCL_PLY_WRITE = False
SET_PRESET = False


def start_pipeline(serial_number):
    pipeline = rs.pipeline(ctx)
    cfg = rs.config()
    cfg.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 10)
    cfg.enable_device(serial_number)
    pipeline.start(cfg)
    print_verbose("Started pipeline - " + serial_number)
    return pipeline


def start_pipelines(serial_numbers):
    print_verbose('Starting pipelines')
    pipelines = list()
    for device_num in range(ctx.query_devices().size()):
        pipelines.append(start_pipeline( serial_numbers[device_num]))
    return pipelines


def close_pipelines(pipelines):
    print_verbose('Closing pipelines')
    for pipeline in pipelines:
        serial_number = str(pipeline.get_active_profile().get_device().get_info(rs.camera_info.serial_number))
        print_verbose("Closing pipeline - " + serial_number)
        pipeline.stop()


def find_all_devices():
    global presets
    print_verbose('Looking for connected devices')
    serial_numbers = list()
    cont = None
    print(str(ctx.query_devices().size()) + ' devices were detected.')
    while True:
        cont = input("Is this the right amount of cameras connected? y/n : ")
        if cont.lower() not in ('y', 'n'):
            print("Please enter only \'y\' or \'n\'")
        else:
            break
    if cont == "n":
        sys.exit('Please make sure all cameras are connected properly.')

    print_verbose("searching for devices...")


    temp = list()
    depth_sensors = list()
    for device in ctx.sensors:
        temp.append(device.get_info(rs.camera_info.serial_number))
        if device.is_depth_sensor():
            depth_sensor = device.as_depth_sensor()
            if SET_PRESET is False:
                preset_range = depth_sensor.get_option_range(rs.option.visual_preset)
                presets = list(range(0, int(preset_range.max)))
            depth_sensor.set_option(rs.option.visual_preset, presets[0])
            depth_sensors.append(depth_sensor)

    depth_sensors.sort(key=lambda x: x.get_info(rs.camera_info.serial_number))

    serial_numbers = sorted(list(dict.fromkeys(temp)))

    for sn in serial_numbers:
        print("Device detected. S/N - " + sn)

    if (len(serial_numbers) != ctx.query_devices().size()):
        sys.exit('An error has occurred. One or more of the cameras were disconnected.')



    return serial_numbers, depth_sensors


def set_depth_sensors_preset(depth_sensors):
    global preset
    for depth_sensor in depth_sensors:
        depth_sensor.set_option(rs.option.visual_preset, presets[preset])


def resize_image(image):
    W, H = screensize
    height, width, depth = image.shape

    scaleWidth = float(W) / float(width)
    scaleHeight = float(H) / float(height)
    if scaleHeight > scaleWidth:
        imgScale = scaleWidth
    else:
        imgScale = scaleHeight

    newX, newY = image.shape[1] * imgScale, image.shape[0] * imgScale
    newimg = cv2.resize(image, (int(newX), int(newY)))

    return newimg


def show_depth_images(frames, serial_numbers):
    depth_colorized_frames = []
    for frame in frames:
        depth_frame = frame.get_depth_frame()
        colorized_depth = np.asanyarray(colorizer.colorize(depth_frame).get_data())
        depth_colorized_frames.append(colorized_depth)

    image = resize_image(cv2.hconcat(depth_colorized_frames))
    window_name = 'Depth Images From - '
    for serial_number in serial_numbers:
        window_name = window_name + serial_number + '   '
    view_window = cv2.namedWindow(window_name, cv2.WINDOW_AUTOSIZE)
    cv2.setWindowProperty(window_name, cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
    cv2.setWindowProperty(window_name, cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_NORMAL)
    cv2.imshow(window_name, image)


def show_depth_for_preset(pipelines, serial_numbers):
    frames = []
    for pipeline in pipelines:
        frames.append(pipeline.wait_for_frames())
    show_depth_images(frames, serial_numbers)


def create_directory(path):
    try:
        shutil.rmtree(path, ignore_errors=True)
        os.makedirs(path)
    except OSError:
        sys.exit("Creation of the directory %s failed" % path)
    else:
        print_verbose('created directory - ' + path)


def get_pipeline_sn(pipeline):
    return str(pipeline.get_active_profile().get_device().get_info(rs.camera_info.serial_number))


def take_picture_thread(frame_list, pipeline):
    frames = pipeline.wait_for_frames()
    frame_list.append((frames, pipeline))


def change_preset(pipelines, serial_numbers, depth_sensors):

    print("Press \'p\' to change camera mode. Press \'c\' to start capturing depth frames.")
    global preset
    cont = True
    while cont is True:
        show_depth_for_preset(pipelines, serial_numbers)
        key = cv2.waitKey(1)
        if key == ord("p"):

            preset = preset + 1
            preset_range = depth_sensors[0].get_option_range(rs.option.visual_preset)
            preset = preset % len(presets)
            preset_name = ''
            for depth_sensor in depth_sensors:
                depth_sensor.set_option(rs.option.visual_preset, presets[preset])
                preset_name = depth_sensor.get_option_value_description(rs.option.visual_preset, presets[preset])
            print_verbose('Change preset to - ' + str(presets[preset]) + ', ' + str(preset_name))
        if key == ord("c"):
            cv2.destroyAllWindows()
            cv2.waitKey(1)
            time.sleep(0.1)
            cont = False


def taking_pictures(pipelines, frames):
    threads = list()
    for pipeline in pipelines:
        x = threading.Thread(target=take_picture_thread, args=(frames, pipeline,))
        threads.append(x)
        x.start()

    for thread in threads:
        thread.join()


def show_taken_pictures(frames, serial_numbers):

    for i in range(15):
        show_frames = []
        for camera_frames in frames:
            show_frames.append(camera_frames[i])
        show_depth_images(show_frames, serial_numbers)
        cv2.waitKey(TIME_TO_SHOW_IMAGES)

    cv2.destroyAllWindows()
    cv2.waitKey(1)


def save_depth_frame(frame, serial_number, file_name):

    print_verbose("Saving to " + file_name)
    ply = rs.save_to_ply(file_name)

    # Set options to the desired values
    # In this example we'll generate a textual PLY with normals (mesh is already created by default)
    ply.set_option(rs.save_to_ply.option_ply_binary, True)
    ply.set_option(rs.save_to_ply.option_ply_normals, args.normals)

    # Apply the processing block to the frameset which contains the depth frame and the texture

    colorized = colorizer.process(frame)
    ply.process(colorized)


def start_timer(seconds):
    print('Capturing in')
    while seconds > 0:
        print(str(seconds) + " ...")
        time.sleep(1)
        seconds -= 1


def restart_pipelines(pipelines, serial_numbers, depth_sensors):
    print_verbose("restarting pipelines")
    close_pipelines(pipelines)
    pipelines = start_pipelines(serial_numbers)
    set_depth_sensors_preset(depth_sensors)
    return pipelines


def frames_for_calibration(pipelines, serial_numbers,depth_sensors):
    print_verbose('Capturing depth frames for RANSAC calibration.')
    print_verbose('Please place the ball in the where all the cameras can see it.')
    change_preset(pipelines, serial_numbers, depth_sensors)


    for round_number in range(NUMBER_OF_PICTURES_FOR_CALIBRATION):

        start = time.time()
        save_images_threads = list()
        round_frames = []
        for i in range(len(serial_numbers)):
            round_frames.append([])
        frequency = 500  # Set Frequency To 2500 Hertz
        duration = 1000  # Set Duration To 1000 ms == 1 second
        winsound.Beep(frequency, duration)
        for i in range(15):
            capture_frames = []
            taking_pictures(pipelines, capture_frames)
            for frame_tuple in capture_frames:
                frame = frame_tuple[0]
                pipeline = frame_tuple[1]
                index = pipelines.index(pipeline)
                round_frames[index].append(frame)
                serial_number = serial_numbers[index]
                file_name = CALIBRATION_DIR
                file_name = file_name + serial_number + '_' + ("{0:0=2d}".format(15 * round_number + i)) + ".ply"

                y = threading.Thread(target=save_depth_frame, args=(frame, serial_number, file_name,))
                save_images_threads.append(y)
                y.start()



        frequency = 750  # Set Frequency To 2500 Hertz
        duration = 500  # Set Duration To 1000 ms == 1 second
        winsound.Beep(frequency, duration)
        x = threading.Thread(target=show_taken_pictures, args=(round_frames, serial_numbers,))
        x.start()
        print_verbose('Saving time - ' + str(time.time() - start) + ' seconds')
        print_verbose('Saved depth frames - round ' + str(round_number+1))

        print_verbose('Maximum frames limit was reached. Please wait.')

        for thread in save_images_threads:
            thread.join()
        pipelines = restart_pipelines(pipelines, serial_numbers, depth_sensors)
        x.join()

    cv2.destroyAllWindows()
    cv2.waitKey(1)
    print_verbose('Done capturing depth frames for calibration.')
    return pipelines


def save_calib_frames(frames, serial_numbers):
    for cam_index, camera_frames in enumerate(frames):
        for num_of_frame, frame in enumerate(camera_frames):
            file = ""
            file_name = CALIBRATION_DIR
            file_name = file_name + serial_numbers[cam_index] + '_' + ("{0:0=2d}".format(num_of_frame)) + ".ply"

            save_depth_frame(frame, serial_numbers[cam_index], file_name)


def save_depth_session(frames, serial_numbers, round):
    for cam_index, camera_frames in enumerate(frames):
        for num_of_frame, frame in enumerate(camera_frames):
            file = ""
            file_name = CALIBRATION_DIR
            file_name = file_name + serial_numbers[cam_index] + '_' + ("{0:0=2d}".format(15*round+num_of_frame)) + ".ply"

            save_depth_frame(frame, serial_numbers[cam_index], file_name)


def print_verbose(print_str):
    if args.verbose:
        print(print_str)


def main():

    pipelines = list()

    try:
        serial_numbers, depth_sensors = find_all_devices()

        pipelines = start_pipelines(serial_numbers)
        number_of_cameras = len(serial_numbers)
        start = time.time()
        if args.calibrate is True:
            create_directory(CALIBRATION_DIR)
            pipelines = frames_for_calibration(pipelines, serial_numbers, depth_sensors)
        print_verbose('Calibration time - ' + str(time.time() - start))

        lc = string.ascii_lowercase[:NUMBER_OF_CAPTURES]
        if CAPTURE is True:
            create_directory(CAPTURES_DIR)
            for round_ind, round_letter in enumerate(lc):
                frames = list()
                print_verbose('Round - ' + str(round_ind + 1))
                print('Press c to capture depth images')
                change_preset(pipelines, serial_numbers, depth_sensors)
                time.sleep(0.1)
                start_timer(TIME_FOR_TIMER)

                start = time.time()
                taking_pictures(pipelines, frames)
                print_verbose('Capturing time - ' + str(1000 * (time.time()-start)) + ' milliseconds')
                for frame_tuple in frames:
                    frame = frame_tuple[0]
                    pipeline = frame_tuple[1]
                    serial_number = get_pipeline_sn(pipeline)
                    file_name = CAPTURES_DIR + round_letter + "_" + serial_number + ".ply"
                    save_depth_frame(frame, serial_number, file_name)



    except Exception as e:
        print('Error!')
        print(e)

    finally:
        close_pipelines(pipelines)



if __name__ == "__main__":

    dir_path = os.path.dirname(os.path.realpath(sys.argv[0]))
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=str, default=dir_path ,help='path to the source directory')
    parser.add_argument('name', type=str, help='name of the captures directory')
    parser.add_argument('--calibrate', help='run calibration', action='store_true')
    parser.add_argument('--calNum', type=int, nargs=1, help='number of calibration frames', default=29)
    parser.add_argument('--capture', help='run capturing', action='store_true')
    parser.add_argument('--capNum', type=int, nargs=1, help='number of capture frames', default=5)
    parser.add_argument('--timer', type=int, nargs=1, help='time for timer before capturing in seconds', default=0)
    parser.add_argument('--showTime', type=int, nargs=1, help='time to show captures in milliseconds', default=200)
    parser.add_argument('--verbose', help='print optional output', action='store_true')
    parser.add_argument('--preset', help='choose only relevant presets', action='store_true')
    parser.add_argument('--normals', help='save normals', action='store_true')
    args = parser.parse_args()
    CALIBRATION_DIR = args.source + '\\calibration\\'
    CAPTURES_DIR = args.source + '\\' + args.name + '\\'

    NUMBER_OF_CAPTURES = args.capNum
    TIME_FOR_TIMER = args.timer
    NUMBER_OF_PICTURES_FOR_CALIBRATION = args.calNum
    TIME_TO_SHOW_IMAGES = args.showTime

    CALIBRATE_CAMERAS = args.calibrate
    CAPTURE = args.capture
    SET_PRESET = args.preset

    main()