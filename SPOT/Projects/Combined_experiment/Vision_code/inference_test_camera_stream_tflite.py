import numpy as np
import cv2
from tensorflow import keras
import tensorflow as tf
import sys
import time
import SPOTPoseNet
import os
#import matplotlib.pyplot as plt
import math

outputYawSize = 128
image_size = 448

def run_model():
    print(tf.__version__)
    keras.backend.clear_session()
    path_to_weights = sys.argv[1]
#    path_to_foler = sys.argv[2]

    print("loading with leaky relu")
    model_in = keras.models.load_model(path_to_weights, custom_objects={'LeakyReLU': tf.keras.layers.LeakyReLU},
                                    compile=True)

    converter = tf.lite.TFLiteConverter.from_keras_model(model_in)
    converter.optimizations = [tf.lite.Optimize.OPTIMIZE_FOR_SIZE]
    model_converter = converter.convert()
    model_interpreter = tf.lite.Interpreter(model_content=model_converter)
    model_interpreter.allocate_tensors()

    print("TFLITE MADE")
    input_details = model_interpreter.get_input_details()
    output_details = model_interpreter.get_output_details()

    #model.summary()

    count_idx = 0

    average_x_error = 0
    average_y_error = 0
    average_yaw_error = 0
    cap = cv2.VideoCapture(1)
    ret, frame = cap.read()

    while True:
        start = time.time()


#        plt.xlim(-0.8, 0.8)
#        plt.ylim(0.5, 2.0)
        left = np.zeros(shape=(1, image_size, image_size, 1), dtype='float32')
        right = np.zeros(shape=(1, image_size, image_size, 1), dtype='float32')

        stereoFrame = np.split(frame, 2, axis=1)

#        left[:,:,:,0] = cv2.resize(stereoFrame[0], (image_size, image_size))
#        right[:,:,:,0] = cv2.resize(stereoFrame[1], (image_size, image_size))
        left[:,:,:,0] = cv2.cvtColor(cv2.resize(stereoFrame[0], (image_size, image_size)), cv2.COLOR_BGR2GRAY)
        right[:,:,:,0] = cv2.cvtColor(cv2.resize(stereoFrame[1], (image_size, image_size)), cv2.COLOR_BGR2GRAY)
        stacked_stereo = np.concatenate((left, right), axis=3)
        #print("Shape:")
        #print(np.shape(stacked_stereo))
        # output = model(stacked_stereo)
        #output = model.predict(stacked_stereo)


        model_interpreter.set_tensor(input_details[0]['index'], stacked_stereo)
        model_interpreter.invoke()
        outputX = model_interpreter.get_tensor(output_details[0]['index'])
        outputY = model_interpreter.get_tensor(output_details[1]['index'])
        outputClass = model_interpreter.get_tensor(output_details[2]['index'])
        outputYaw = model_interpreter.get_tensor(output_details[3]['index'])

        end = time.time()
        # os.system('clear')
        # print("\nOutput:")
        print(outputX)
        print(outputY)
        print(outputYaw)
        print(outputClass)

        # x = float(output[0] + 1.465011268)  # 0.75696775)
        # y = float(output[1] - 0.05722763)   # 0.14045002)
        # # yaw = float(output[2]*2*math.pi) - math.pi  # 1.79890046)
        # #
        # maxIdxVal = 0
        # maxIdx = 0
        # outputIndexs = output[2]
        # for yawIdx in range(0, outputYawSize):
        #     if float(outputIndexs[0, yawIdx]) > maxIdxVal:
        #         maxIdxVal = float(outputIndexs[0, yawIdx])
        #         maxIdx = yawIdx
        #
        # yaw = ((maxIdx + 1) / outputYawSize) * 2 * math.pi - math.pi
        # #
        # # # if save_file:
        # # #     save_file.write(str(x) + '\t' + str(y) + '\t' + str(yaw) + '\t' + str(output[3]) + '\n')
        # print("X: " + str(x) + " Y: " + str(y) + " Yaw: " + str(yaw) + " confidence: " + str(output[3]))
        # # print("Ground Truth")
        # print("X: " + str(test_labels[count_idx][0]) + " Y: " + str(test_labels[count_idx][1]) + " Yaw: " + str(test_labels[count_idx][2]))
        # #
        # yaw_erorr = abs(test_labels[count_idx][2] - yaw)
        #
        # if yaw_erorr > 2*math.pi:
        #     yaw_erorr = yaw_erorr - 2*math.pi
        #
        # print("Difference")
        # average_x_error = average_x_error + abs(test_labels[count_idx][0] - x)
        # average_y_error = average_y_error + abs(test_labels[count_idx][1] - y)
        # average_yaw_error = average_yaw_error + yaw_erorr
        #
        # # print("Difference")
        # # average_x_error = average_x_error + abs(test_labels[count_idx][0])
        # # average_y_error = average_y_error + abs(test_labels[count_idx][1])
        # # average_yaw_error = average_yaw_error +abs(test_labels[count_idx][2])
        #
        # print("X: " + str(abs(test_labels[count_idx][0] - x)) + " Y: " + str(abs(test_labels[count_idx][1] - y)) + " Yaw: " + str(yaw_erorr))
        # count_idx = count_idx + 1
        print("Time " + str(end - start))
        ret, frame = cap.read()

        # cv2.imshow('image', cv2.resize(stereoFrame[0], (image_size, image_size)))
        # print(testImage)
        # cv2.waitKey(1)
    print("Average Error for this model")
    print("Average -> ")
    print(np.mean(test_labels[:, 3]))
    print("STD -> ")
    print(np.std(test_labels[:, 3]))

    average_x_error = average_x_error / count_idx
    average_y_error = average_y_error / count_idx
    average_yaw_error = average_yaw_error / count_idx

    print("Average Error for this model")
    print("Average X Error -> " + str(average_x_error))
    print("Average Y Error -> " + str(average_y_error))
    print("Average Yaw Error -> " + str(average_yaw_error))

if __name__ == "__main__":
    run_model()
