import numpy as np
import cv2
from tensorflow import keras
import tensorflow as tf
import sys
import time
import SPOTPoseNet
import os
import CustomVideoDataGenerator
import CustomImageDataGenerator
#import matplotlib.pyplot as plt
import math

def run_model_recorded_video():
    #print(tf.__version__)
    keras.backend.clear_session()
    #conf = tf.ConfigProto()
    gpus = tf.config.experimental.list_physical_devices('GPU')
    tf.config.experimental.set_memory_growth(gpus[0], True)

    path_to_weights = sys.argv[1]
    path_to_video_file = sys.argv[2]
    print_to_file = False

    save_file = ''
    if print_to_file:
        save_file = open('model_output_' + str(time.time()) + '.txt', 'w')
        save_file.write('X\t' + 'Y\t'  + 'Yaw\t' + 'Confidence\n')

    # path_to_ground_truth = sys.argv[3]

    print("loading with leaky relu")
    model = keras.models.load_model(path_to_weights, custom_objects={'LeakyReLU': tf.keras.layers.LeakyReLU,
                                                                     'custom_loss': SPOTPoseNet.custom_loss,
                                                                     'custom_metric': SPOTPoseNet.custom_metric}, compile=False)
    print("Loaded")

    model.summary()

    cap = cv2.VideoCapture(path_to_video_file)

    ret, frame = cap.read()
    previous = []
    previous_gt = []

    #plt.xlim(-0.8, 0.8)
    #plt.ylim(0.5, 2.0)
    left = np.zeros(shape=(1, 448, 448, 1), dtype='uint8')
    right = np.zeros(shape=(1, 448, 448, 1), dtype='uint8')

    estimatedPos = []

    frameIdx = 0
    while(ret):
        frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        start = time.time()

        stereoFrame = np.split(frame, 2, axis=1)

        left[:,:,:,0] = cv2.resize(stereoFrame[0], (448, 448))
        right[:,:,:,0] = cv2.resize(stereoFrame[1], (448, 448))

        #cv2.imshow('image', cv2.resize(stereoFrame[0], (320, 320)))
        #cv2.waitKey(100)

        stacked_stereo = np.concatenate((left, right), axis=3)
        #print("Shape:")
        #print(np.shape(stacked_stereo))
#        start = time.time()
        output = model(stacked_stereo, training=False)

        end = time.time()
        os.system('clear')
        print("Inference time: " + str(end-start))
        print("\nOutput:")
        print(output)
        x = float(output[0]) + 0.96756636 #+ 0.96760507)  # 0.75696775)
        y = float(output[1]) - 0.01050488 #- 0.01183383)  # 0.14045002)
        yaw = (float(output[2])*2*math.pi)-math.pi #- 0.00143911)  # 1.79890046)

        # ground_truth = CustomVideoDataGenerator.getGroundTruth(path_to_ground_truth, frameIdx)
        # if save_file:
        #     save_file.write(str(x) + '\t' + str(y) + '\t' + str(yaw) + '\t' + str(output[3]) + '\n')

        estimatedPos.append(str(x) + '\t' + str(-y) + '\t' + str(yaw) + '\t')

        print("X: " + str(x) + " Y: " + str(y) + " Yaw: " + str(yaw) + " confidence: " + str(output[3]))
        # print("Ground Truth")
        # print("X: " + str(ground_truth[0]) + " Y: " + str(ground_truth[1]) + " Yaw: " + str(ground_truth[2]))
        # #
        # print("Difference")
        # print("X: " + str(abs(ground_truth[0] - x)) + " Y: " + str(abs(ground_truth[1] - y)) + " Yaw: " + str(abs(ground_truth[2] - yaw)))

        #diff_x = abs(ground_truth[0] - x)
        #diff_y = abs(ground_truth[1] - y)

        #if previous:
            #x1, y1 = [previous[0], x], [previous[1], y]
            #x2, y2 = [previous_gt[0], ground_truth[0]], [previous_gt[1], ground_truth[1]]
            #plt.plot(x1, y1, 'r-')
            #plt.plot(x2, y2, 'b-')
        #previous = [x, y]
        #previous_gt = [ground_truth[0], ground_truth[1]]
        # if output[3] > 0.75:
        #     plt.scatter(-y, x, c='r')
        # plt.scatter(-ground_truth[1], ground_truth[0], c='b')
        # #plt.scatter(ground_truth[1], diff_y, c='b')
        # plt.draw()
        # plt.pause(0.01)
        ret, frame = cap.read()
        frameIdx += 1

    #file = "./PrintedPose.txt"
    #with open(file, 'w') as f:
    #    for item in estimatedPos:
    #        f.write("%s\n" % item)

    print("\n\nVideo completed\n\n")
    # plt.pause(50)

def run_model():
    #print(tf.__version__)
    keras.backend.clear_session()
    path_to_weights = sys.argv[1]
    image_path = sys.argv[2]
    path_to_ground_truth = sys.argv[3]
    print_to_file = False

    save_file = ''
    if print_to_file:
        save_file = open('model_output_' + str(time.time()) + '.txt', 'w')
        save_file.write('X\t' + 'Y\t'  + 'Yaw\t' + 'Confidence\n')

    path_to_ground_truth = sys.argv[3]

    print("loading with leaky relu")
    model = keras.models.load_model(path_to_weights, custom_objects={'LeakyReLU': tf.keras.layers.LeakyReLU,
                                                                     'custom_loss': SPOTPoseNet.custom_loss,
                                                                     'custom_metric': SPOTPoseNet.custom_metric})
    print("Loaded")

    model.summary()

    frame = cv2.imread(image_path, 0)

    plt.xlim(-0.8, 0.8)
    plt.ylim(0.5, 2.0)
    left = np.zeros(shape=(1, 320, 320, 1), dtype='uint8')
    right = np.zeros(shape=(1, 320, 320, 1), dtype='uint8')

    stereoFrame = np.split(frame, 2, axis=1)

    left[:,:,:,0] = cv2.resize(stereoFrame[0], (320, 320))
    right[:,:,:,0] = cv2.resize(stereoFrame[1], (320, 320))

    cv2.imshow('image', cv2.resize(stereoFrame[0], (320, 320)))
    cv2.waitKey(1)

    stacked_stereo = np.concatenate((left, right), axis=3)
    #print("Shape:")
    #print(np.shape(stacked_stereo))
    output = model.predict(stacked_stereo)

    end = time.time()
    os.system('clear')
    print("\nOutput:")
    print(output)
    x = float(output[0] + 0.96760507)  # 0.75696775)
    y = float(output[1] - 0.01183383)  # 0.14045002)
    yaw = float(output[2] - 0.00143911)  # 1.79890046)

    decodedData = CustomImageDataGenerator.PositionalData(CustomImageDataGenerator.getLabel(path_to_ground_truth))
    ground_truth = [None] * 4
    ground_truth[0], ground_truth[1], ground_truth[2] = decodedData.getRelativeBlackPoseFromRed()
    # if save_file:
    #     save_file.write(str(x) + '\t' + str(y) + '\t' + str(yaw) + '\t' + str(output[3]) + '\n')
    print("X: " + str(x) + " Y: " + str(y) + " Yaw: " + str(yaw) + " confidence: " + str(output[3]))
    print("Ground Truth")
    print("X: " + str(ground_truth[0]) + " Y: " + str(ground_truth[1]) + " Yaw: " + str(ground_truth[2]))
    #
    print("Difference")
    print("X: " + str(abs(ground_truth[0] - x)) + " Y: " + str(abs(ground_truth[1] - y)) + " Yaw: " + str(abs(ground_truth[2] - yaw)))


if __name__ == "__main__":
    run_model_recorded_video()
