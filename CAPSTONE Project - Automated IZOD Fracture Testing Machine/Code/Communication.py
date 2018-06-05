# -*- coding: utf-8 -*-
import os.path
import time
import numpy as np
import serial


def readpref():
    """Fetches information from preferences.txt.

    If preferences.txt exists, fetches appropriate constants.
    If it doesn't revert to default constants.

    Args:
        
    Returns:
        A set of constants used in calculations of output values.

        count: Test File Count
        timesensitivity: Average time between each data point in 
            the previous test
        timefactor: Unused
        armradius: Length of the arm from point of rotation to center of mass
        maxencstep: Maximum encoder step
        initialanglestep: Encoder step corresponding to the initial height,
            updated every run
        mass0: Mass of the hammer without weights
        mass1: Mass of the hammer with small plates
        mass2: Mass of the hammer with medium plates
        mass3: Mass of the hammer with Large plates 
        mass0calibangle: Height loss on a free swing without weights
        mass1calibangle: Height loss on a free swing with small plates
        mass2calibangle: Height loss on a free swing with merdium plates
        mass3calibangle: Height loss on a free swing with large plates
        Larm0: Length of the arm from center of rotation to center of mass 
            without weights
        Larm1: Length of the arm from center of rotation to center of mass
            with small plates
        Larm2: Length of the arm from center of rotation to center of mass
            with medium plates
        Larm3: Length of the arm from center of rotation to center of mass
            with large plates
    """
    try:
        if os.path.isfile("preferences.txt"):
            Fc = open("preferences.txt", "r")
            readlines = Fc.readlines()
            testread = [line.split("\t") for line in readlines]
            Fc.close()
            count = int(testread[0][1])
            timesensitivity = float(testread[1][1])
            timefactor = float(testread[2][1])
            armradius = float(testread[3][1])
            maxencstep = int(testread[4][1])
            initialanglestep = int(testread[5][1])
            mass0 = float(testread[6][1])
            mass1 = float(testread[7][1])
            mass2 = float(testread[8][1])
            mass3 = float(testread[9][1])
            mass0calibangle = float(testread[10][1])
            mass1calibangle = float(testread[11][1])
            mass2calibangle = float(testread[12][1])
            mass3calibangle = float(testread[13][1])
            Larm0 = float(testread[14][1])
            Larm1 = float(testread[15][1])
            Larm2 = float(testread[16][1])
            Larm3 = float(testread[17][1])
    
        elif not os.path.isfile("preferences.txt"):
            count = 0
            timesensitivity = 10
            initialanglestep = 3723
            maxencstep = 10000
            armradius = 359.918
            timefactor = 1.5
            mass0 = 414.1
            mass1 = 943.0
            mass2 = 2060.8
            mass3 = 3355.8
            mass0calibangle = 130.14
            mass1calibangle = 131.9238
            mass2calibangle = 132.8652
            mass3calibangle = 133.128
            Larm0 = 283.58
            Larm1 = 338.96
            Larm2 = 365.54
            Larm3 = 379.13
    except:
        pass
    
    return count,timesensitivity,timefactor,armradius,maxencstep,\
    initialanglestep,mass0,mass1,mass2,mass3,mass0calibangle,mass1calibangle,\
    mass2calibangle,mass3calibangle,Larm0,Larm1,Larm2,Larm3

def calc_angle(angle,length):
    """Calculates the vertical height of the 
    pendulum depending on the encoder readings

    Args:
        angle: encoder readings in degrees
        length: length of the pendulum arm
        
    Returns:
        The maximum Height reached by the hammer

        height: vertical height of the pendulum
    """
    Height = length - length * np.cos(np.deg2rad(angle))

    return Height

def vecreset():
    """Resets the time, encoder data, accelerometer data lists to empty lists

    Args:
        
    Returns:
        Empty lists

        timepoints: Empty list corresponding to the time(ms) for each 
            encoder data point
        timepointsacc: Empty list corresponding to the time(ms) for each 
            accelerometer data point
        enc: Empty list corresponding to each encoder data point
        acc: Empty list corresponding to each accelerometer data point
    """
    
    timepoints = []
    timepointsacc = []
    enc = []
    acc = []

    return timepoints, timepointsacc, enc, acc

def prefline(file, name, var):
    """Template for added lines in the output text file

    Args:
        file: text file name
        name: User input name
        var: User input variable
        
    Returns:
    """
    
    file.write(name + ":")
    file.write("\t")
    file.write(str(var))
    file.write("\n")


def sizecompare(vec1, vec2):
    """Two uneven lists made into even lists

    Args:
        vec1: A first list
        vec2: A second list
        
    Returns:
        Removes values at the end of the larger list until both lists are of
        the same length

        vec1: A first list
        vec2: A second list
    """
    
    if len(vec1) > len(vec2):
        vec1 = vec1[len(vec1)-len(vec2):len(vec1)]
    elif len(vec1) < len(vec2):
        vec2 = vec2[len(vec2)-len(vec1):len(vec2)]
    return vec1, vec2

def startread(SerialData): 
    """Only used when __name__ == '__main__' to simulate the GUI button presses

    Args:
        SerialData: Arduino COM port
        
    Returns:
        Returns a char corresponding to the simulated button press.
        Refer to readard()

        command: Character
        
    """
    
    command = input("Write to start: ").upper()
    if command == "B" or command == "C" or command == "D" or command == "E" or command == "Q":
        pass
    else:
        print("Wrong input")
        startread(SerialData) 
    return command

def StartArduino(comport, bd):
    """Only used when __name__ == '__main__' to open the arduino port

    Args:
        comport: COM port of the arduino
        bd: Baudwidth
        
    Returns:
        Returns a string corresponding to the adequate Arduino COM port

        SerialData: Adequate String Arduino COM port
    """
    
    try:
        SerialData = serial.Serial(comport, bd)
    except:
        SerialData(comport, bd).close()
        SerialData = serial.Serial(comport, bd)
    return SerialData

def savedata(timepoints,timepointsacc, enc, acc):
    """Saves all the data sets into a DATA.txt file

    Args:
        timepoints: Llist corresponding to the time(ms) for each 
            encoder data point
        timepointsacc: List corresponding to the time(ms) for each 
            accelerometer data point
        enc: List corresponding to each encoder data point
        acc: List corresponding to each accelerometer data point
        
    Returns:
    """
    
    F = open("DATA.txt", "w")
    for i in range(0,len(timepoints)):
        F.write(str(timepoints[i]))
        F.write(",")
        F.write(str(enc[i]))
        F.write(",")
        try:
            F.write(str(timepointsacc[i]))
        except:
            F.write("N/A")
        F.write(",")
        try:
            F.write(str(acc[i]))
        except:
            F.write("N/A")
        F.write("\n")
    F.close()


def readard(SerialData, command):
    """Main arduino reading function
    
    Args:
        SerialData: COM port of the arduino
        command: Character corresponding to a button press
        
    Returns:
        command == B:
            Run routine. 
            The magnet engages and the hammer is lifted to a 610mm+/-2
            vertical height then the magnet disengages and the hammer is 
            dropped 2 seconds later. The data for a single swing is recorded,
            plotted and transformed on the GUI, 
            and saved in an output text file.
    
        command == C:
            Reset routine. 
            The magnet engages and the lifting arm is returned to 
            the original position
        
        command == D:
            Loading routine. 
            The magnet engages and the hammer is lifted out
            of the way to allow the placement of a specimen in the vice. if the
            command is given again, the hammer is lowered to its initial position.
            
        command == E:
            Calibration routine.
            The magnet engages and the hammer is lifted 10 degrees from its 
            current position. The magnet then disengages and the hammer is dropped.
            Once the hammer stabilizes at 0 degrees, the command can be sent again
            to have the current encoder position of the hammer recorded as 
            the 0 position and the lifting arm will connect to the hammer and 
            return itself to that position.
            
        command == Q:
            Stops the program.
    """
    
    timepoints, timepointsacc, enc, acc = vecreset()
    count,timesensitivity,timefactor,armradius,maxencstep,initialanglestep,\
    mass0,mass1,mass2,mass3,mass0calibangle,mass1calibangle,mass2calibangle,\
    mass3calibangle,Larm0,Larm1,Larm2,Larm3 = readpref()

    if command == "B":
        
        # flush any junk left in the serial buffer
        SerialData.reset_input_buffer()
        command = command.encode("utf-8")
        SerialData.write(command)
        time.sleep(0.05)
        run = True
        while run:
            data = SerialData.readline().decode("utf-8")

            if "?" in data:
                try:
                    datarecacc = data.split("\t")
                    timepointsacc.append(float(datarecacc[1]))
                    acc.append(float(datarecacc[2])*3.3/4095/0.0099)
                except:
                    pass
            else:
                try:
                    datarec = data.split("\t")
                    timepoints.append(float(datarec[0]))
                    enc.append(int(datarec[1]))
                except:
                    pass
            
            if data in ["reset\r\n"]:
                initialanglestep = np.max(enc)
                Height_step = np.abs(np.min(enc))
                
                acc = acc[1:len(acc)+1]
                timepoints, enc = sizecompare(timepoints, enc)
                timepointsacc, acc = sizecompare(timepointsacc, acc)
                timepoints = [i-timepoints[0] for i in timepoints]
                acc = [i-acc[0] for i in acc]
                
                savedata(timepoints, timepointsacc, enc, acc)
                
                initial_angle = float(initialanglestep)*360/float(maxencstep)
                end_angle = float(Height_step)*360/float(maxencstep)
                
                F = open("IZOD"+str(count)+"_"+time.strftime("Date_%m_%d_%Y_Time_%H_%M_%S", time.localtime())+".txt", "w")
                F.write(time.strftime("%a, %d, %b, %Y, %H:%M:%S", time.localtime()))
                F.write("\n")
                prefline(F,"File Number",count)
                prefline(F,"Initial Angle (degrees)",initial_angle)
                prefline(F,"Final Angle (degrees)",end_angle)
                F.write("\n")
                F.close()

                count = count + 1
                Fc = open("preferences.txt", "w")
                prefline(Fc, "Count", count)
                prefline(Fc, "Time_Sensitivity_ms", timesensitivity)
                prefline(Fc, "Time_Factor", timefactor)
                prefline(Fc, "Arm_Radius_mm", armradius)
                prefline(Fc, "Max_encoder_Step", maxencstep)
                prefline(Fc, "Initial_Angle_Step", initialanglestep)
                prefline(Fc, "Mass_0_g", mass0)
                prefline(Fc, "Mass_1_g", mass1)
                prefline(Fc, "Mass_2_g", mass2)
                prefline(Fc, "Mass_3_g", mass3)
                prefline(Fc, "Mass_0_calib_angle_deg", mass0calibangle)
                prefline(Fc, "Mass_1_calib_angle_deg", mass1calibangle)
                prefline(Fc, "Mass_2_calib_angle_deg", mass2calibangle)
                prefline(Fc, "Mass_3_calib_angle_deg", mass3calibangle)
                prefline(Fc, "Mass_0_L_mm", Larm0)
                prefline(Fc, "Mass_1_L_arm_mm", Larm1)
                prefline(Fc, "Mass_2_L_arm_mm", Larm2)
                prefline(Fc, "Mass_3_L_arm_mm", Larm3)
                Fc.close()
                
                timepoints, timepointsacc, enc, acc = vecreset()
                run = False
                
    if command == "C":
        SerialData.reset_input_buffer()
        command = command.encode("utf-8")
        SerialData.write(command)
        time.sleep(0.05)
    
    if command == "D":
        SerialData.reset_input_buffer()
        command = command.encode("utf-8")
        SerialData.write(command)
        time.sleep(0.05)
    
    if command == "E":
        SerialData.reset_input_buffer()
        command = command.encode("utf-8")
        SerialData.write(command)
        time.sleep(0.05)
        
    if command == "Q":
        SerialData.reset_input_buffer()
        command = command.encode("utf-8")
        SerialData.write(command)
        time.sleep(0.05)

if __name__ == '__main__':
    SerialData = StartArduino("com8", 250000)
    while True:
        command = startread(SerialData)
        readard(SerialData, command)
        if command == "Q":
            command = "C"
            readard(SerialData, command)
            break
    SerialData.close()
