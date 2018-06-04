# -*- coding: utf-8 -*-
import glob
import Communication as cm
import numpy as np
import serial
import tkinter as tk
from tkinter.scrolledtext import ScrolledText
from matplotlib.figure import Figure
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import (
    FigureCanvasTkAgg, NavigationToolbar2TkAgg)
import matplotlib.animation as animation
from matplotlib import style
import os
import shutil

pause = False
style.use("bmh")
fig = Figure(figsize=(1,1), dpi=60)
ax = fig.add_subplot(111)
list1 = ['No Mass', 'Light Mass', 'Medium Mass', 'Heavy Mass']
g = 9.81

def animate(i):
    """Reads the DATA.txt file and plots its content
    The plot is refreshed every 1s to allow for the next DATA set.

    Args:
        i: counter
        
    Returns:
    """
    
    pullData = open("DATA.txt","r").read()
    dataList = pullData.split('\n')
    timepointsList = []
    timepointsaccList = []
    encList = []
    accList = []
    for eachLine in dataList:
        if len(eachLine) > 1:
            timepoints, enc, timepointsacc, acc = eachLine.split(',')
            try:
                timepointsList.append(float(timepoints))
            except:
                pass
            try:
                encList.append(float(enc))
            except:
                pass
            try:
                timepointsaccList.append(float(timepointsacc))
            except:
                pass
            try:
                accList.append(float(acc))
            except:
                pass
    if not pause:
        ax.clear()
        ax.grid(True)
        ax.plot(timepointsaccList[0:-1], accList[0:-1], "-")
        fig.tight_layout(pad=2.2)
        ax.set_xlabel('Time, milliseconds', fontsize='11', fontstyle='italic')
        ax.set_ylabel('Acceleration, m/s^2', fontsize='11', fontstyle='italic')

def onClick(event):
    """Pauses the animation refresh to allow the user to move or zoom the plot

    Args:
        event: MouseEvent
        
    Returns:
    """

    global pause
    pause ^= True    
    
class App:
    """Main GUI application"""
    
    def note(self):
        """Adds the operator notes to the textfile and output window
        to the previous specimen test run
    
        Args:
            self: Class variables
            
        Returns:
        """
        
        f = open(self.moveto, "r").readlines()
        f.insert(3,"\n")
        opnote = "Operator Notes:\t" + self.entry_4.get(1.0,tk.END)
        f.insert(4,opnote)
        fwrite = open(self.moveto, "w")
        for i in range(0,len(f)):
            fwrite.write(f[i])
        fwrite.close()
        fwrite2 = open(self.moveto, "r").read()
        self.T.delete('1.0', tk.END)
        self.T.insert(tk.END, fwrite2)
        
    def changedir(self):
        """opens the "Change Directory" window
    
        Args:
            self: Class variables
            
        Returns:
        """
        
        self.dir_path = tk.filedialog.askdirectory()
    
    def write_record(self):
        """Run routine and data transformation.
        See accelerometer.py for a description of the run routine.
        
        Modifies the data gathered through the run routine with the input from
        the user entered through the GUI.
        Able to:
            modify DATA in the output text file.
            change the directory.
    
        Args:
            self: Class variables
            
        Returns:
        """
        
        button = "B"        
        cm.readard(self.ser, button)
        Fc = open("preferences.txt", "r")
        readlines = Fc.readlines()
        testread = [line.split("\t") for line in readlines]
        Fc.close()
        self.count = int(testread[0][1])-1
        Fread = glob.glob('IZOD'+str(self.count) + '*.txt')
        self.Fileread = Fread[0]
        f = open(self.Fileread, "r").readlines()
        opname = "Operator Name: " + self.entry_1.get() + "\n"
        f.insert(2,opname)
        f.insert(3,"\n")
        matname = "Specimen Material: " + self.entry_3.get() + "\n"
        f.insert(4,matname)
        f.insert(5,"\n")
        if not self.c.get() == "Select your Mass":
            f.insert(6,"Mass Selected:\t" + self.c.get() + "\n")
        else:
            f.insert(6,"Mass Selected:\t" + "N/A" + "\n")
            
        try:
            f.insert(7,"Specimen Width (mm):\t" + self.entry_2.get() + "\n")
        except:
            f.insert(7,"Specimen Width (mm):\t" + "N/A" + "\n")
            
        try:
            f.insert(8,"Specimen Depth (mm):\t" + self.entry_6.get() + "\n")
        except:
            f.insert(8,"Specimen Depth (mm):\t" + "N/A" + "\n")
        
        f.insert(9,"\n")
        f.insert(10,"UNCORRECTED OUTPUT:\n")
        
        initial_angle = float(f[11].split("\t")[1])
        end_angle = float(f[12].split("\t")[1])
        
        self.armradius = None
        try:
            if self.c.get() == list1[0]:
                mass = self.allmass[0]/1000
                calibangle = self.mass0calibangle
                self.armradius = self.Larm0/1000
            elif self.c.get() == list1[1]:
                mass = self.allmass[1]/1000
                calibangle = self.mass1calibangle
                self.armradius = self.Larm1/1000
            elif self.c.get() == list1[2]:
                mass = self.allmass[2]/1000
                calibangle = self.mass2calibangle
                self.armradius = self.Larm2/1000
            elif self.c.get() == list1[3]:
                mass = self.allmass[3]/1000
                calibangle = self.mass3calibangle
                self.armradius = self.Larm3/1000
            
            Height_initial = cm.calc_angle(initial_angle,self.armradius)
            Height_calib = cm.calc_angle(calibangle,self.armradius)
            Height_end = cm.calc_angle(end_angle,self.armradius)
            
            energy_initial = mass*g*Height_initial
            energy_end = mass*g*Height_end
            energy_calib = energy_initial - mass*g*Height_calib
            
            breakenergy = energy_initial - energy_end
            energy_TC = energy_calib/2*end_angle/calibangle + energy_calib/2
            
            Height_difference = Height_initial - Height_end
            corrected_breakenergy = breakenergy - energy_TC
            
            f.append("Initial Height (mm):\t" + str(Height_initial*1000) + "\n")
            f.append("Final Height (mm):\t" + str(Height_end*1000) + "\n")
            f.append("Height Difference (mm):\t" + str(Height_difference*1000) + "\n")
            f.append("\n")
            
            f.append("CORRECTED OUTPUT:\n")
            f.append("Breaking Energy (J):\t" + str(breakenergy) + "\n")
            f.append("Total Correction Energy (J):\t" + str(energy_TC) + "\n")
            f.append("Corrected Breaking Energy (J):\t" + str(corrected_breakenergy) + "\n")
        except:
            f.append("Initial Height (mm):\t" + "N/A" + "\n")
            f.append("Final Height (mm):\t" + "N/A" + "\n")
            f.append("Height Difference (mm):\t" + "N/A" + "\n")
            f.append("\n")
            
            f.append("CORRECTED OUTPUT: No Mass Selected\n")
            f.append("Breaking Energy (J):\t" + "N/A" + "\n")
            f.append("Total Correction Energy (J):\t" + "N/A" + "\n")
            f.append("Corrected Breaking Energy (J):\t" + "N/A" + "\n")
            
        try:
            impact_resistance = corrected_breakenergy / (float(self.entry_2.get())/1000)
            f.append("Impact Resistance (J/m):\t" + str(impact_resistance) + "\n")
        except:
            f.append("Impact Resistance (J/m):\t" + "N/A" + "\n")
        
        try:
            fracture_toughness = corrected_breakenergy / (float(self.entry_2.get())/1000*float(self.entry_6.get())/1000*2)
            f.append("Impact Strength (Full break) (J/m^2):\t" + str(fracture_toughness) + "\n")
        except:
            f.append("Impact Strength (Full break) (J/m^2):\t" + "N/A" + "\n")
        
        f.append("\n")
        f.append("-"*40+"\n")
        f.append("\n")
        
        fData = open("DATA.txt","r").read()
        dataList = fData.split('\n')
        dataList2 = []
        for eachLine in dataList:
            if len(eachLine) > 1:
                d1,d2,d3,d4 = eachLine.split(',')
                dataList2.append(d1 + "\t")
                dataList2.append(d2 + "\t")
                dataList2.append(d3 + "\t")
                dataList2.append(d4 + "\n")
        
        dataList2.insert(0,"T_enc(ms)" + "\t" + "Enc_data(raw)" + "\t" + "T_acc(ms)" + "\t" + "Acc_data(g)" + "\n")
        f = f + dataList2
        
        fwrite = open(self.Fileread, "w")
        for i in range(0,len(f)):
            fwrite.write(f[i])
        fwrite.close()
        fwrite2 = open(self.Fileread, "r").read()
        self.T.delete('1.0', tk.END)
        self.T.insert(tk.END, fwrite2)
        if self.entry_5.get():
            newname = self.entry_5.get() + "_" + self.Fileread
            self.moveto =  self.dir_path + '/' + newname
            shutil.move(os.path.dirname(os.path.realpath(__file__)) + '/' + self.Fileread, self.moveto)
        elif not self.entry_5.get():
            self.moveto = self.dir_path + '/' + self.Fileread
            shutil.move(os.path.dirname(os.path.realpath(__file__)) + '/' + self.Fileread, self.moveto)
    
    def _quit(self,master):
        """Quits the application and restarts the kernel and resets the hammer
        to the ZERO position.
    
        Args:
            master: tkinter root
        Returns:
        """
        button = "C"
        cm.readard(self.ser, button)
        master.quit()
        master.destroy()
        exit()
        
    def reset_hammer(self):
        """Reset routine.
        See Communication.py for a description.
    
        Args:
            self: Class variables
            
        Returns:
        """
        
        button = "C"
        cm.readard(self.ser, button)
        
    def loading_hammer(self):
        """Loading routine.
        See Communication.py for a description.
    
        Args:
            self: Class variables
            
        Returns:
        """
        
        button = "D"
        cm.readard(self.ser, button)
        
    def calibration(self):
        """Calibration routine.
        See Communication.py for a description.
    
        Args:
            self: Class variables
            
        Returns:
        """
        
        button = "E"
        cm.readard(self.ser, button)
        
    def __init__(self, master, ser):
        """Framework of the application, each block between dotted lines
        represent a different entity (button, canvas, text entry, etc...)
    
        Args:
            self: Class variables
            master: Tkinter app
            ser: Arduino COM port
            
        Returns:
        """
        
        self.allmass = []
        
        self.count,self.timesensitivity,self.timefactor,self.armradius,\
        self.maxencstep,self.initialanglestep,self.mass0,self.mass1,\
        self.mass2,self.mass3,self.mass0calibangle,self.mass1calibangle,\
        self.mass2calibangle,self.mass3calibangle,self.Larm0,\
        self.Larm1,self.Larm2,self.Larm3 = cm.readpref()
        
        self.count = self.count-1
        self.allmass.append(self.mass0)
        self.allmass.append(self.mass1)
        self.allmass.append(self.mass2)
        self.allmass.append(self.mass3)
        
        self.ser  = ser
        
        # Creates the frames where each widget is nested
        buttonwidth = 10
        buttonheight = 3
        buttonfont = 10
        padxgen = 5
        padygen = 2
        container1 = tk.Frame(master, borderwidth=3, relief = tk.RIDGE)
        container1.pack(fill=tk.BOTH, expand = True, side=tk.LEFT)
        container2 = tk.Frame(master, borderwidth=3, relief = tk.RIDGE)
        container2.pack(fill=tk.BOTH, expand = False, side=tk.LEFT)
        topframe = tk.Frame(container1, borderwidth=0, relief = tk.RIDGE)
        topframe.pack(fill=tk.BOTH, expand = True, side=tk.TOP)
        bottomframe = tk.Frame(container2, borderwidth=0, relief = tk.RIDGE)
        bottomframe.pack(fill=tk.BOTH, expand = True, side=tk.BOTTOM)
        textframe = tk.Frame(container1, borderwidth=0, relief = tk.RIDGE)
        textframe.pack(fill=tk.BOTH, expand = False, side=tk.TOP)
        
        bottomframe.grid_rowconfigure(13, weight=1)
        bottomframe.grid_rowconfigure(10, weight=1)
        bottomframe.grid_columnconfigure(0, weight=1)
        bottomframe.grid_columnconfigure(3, weight=1)
        
        # Opens the preferences.txt file to grab the "count" of the previous run
        # and open the adequate output file
        try:
            Fread = glob.glob('DATA/IZOD'+str(self.count) + '*.txt')
            self.Fileread = Fread[0]
        except:
            f = """Waiting for DATA..."""
        
        # ---------------------------------------------------------------------
        # the output text box
        
        try:
            f = open(self.Fileread, "r").read()
        except: pass

        self.scroll = tk.Scrollbar(textframe)
        self.T = tk.Text(textframe, height = 10, width = 1)
        self.scroll.pack(side = tk.RIGHT, fill = tk.Y)
        self.T.pack(fill = tk.BOTH)
        self.scroll.config(command = self.T.yview)
        self.T.config(yscrollcommand = self.scroll.set)
        self.T.insert(tk.END, f)

        # ---------------------------------------------------------------------
        # The quit button
        
        self.quitbutton = tk.Button(bottomframe, 
                             text="QUIT", fg="red",font=("bold",buttonfont),
                             command=lambda master=master:self._quit(master), width = buttonwidth, height = buttonheight)
        self.quitbutton.grid(row = 2, rowspan=1, column = 1, padx = 1, pady = 1, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The run button
        
        self.runbutton = tk.Button(bottomframe,text="RUN",font=("bold",buttonfont),
                                   command=self.write_record, width = buttonwidth, height = buttonheight)
        self.runbutton.grid(row = 2, rowspan=1, column = 2, padx = 1, pady = 1, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The loading button
        
        self.clearbutton = tk.Button(bottomframe, 
                             text="LOADING",font=("bold",buttonfont),
                             command=self.loading_hammer, width = buttonwidth, height = buttonheight)
        self.clearbutton.grid(row = 3, column = 1, padx = 1, pady = 1, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The reset button
        
        self.resetbutton = tk.Button(bottomframe,text="RESET",font=("bold",buttonfont),
                                     command=self.reset_hammer, width = buttonwidth, height = buttonheight)
        self.resetbutton.grid(row = 3, column = 2, padx = 1, pady = 1, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The calibration button
        
        self.calibbutton = tk.Button(bottomframe,text="CALIBRATION", fg="green",font=("bold",buttonfont),
                                     command=self.calibration, width = buttonwidth, height = buttonheight)
        self.calibbutton.grid(row = 13, column = 1, columnspan=2, padx = 1, pady = 1, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The operator note button
        
        self.notebbutton = tk.Button(bottomframe,text="Print Note:", fg="black",font=("bold",buttonfont),
                                     command=self.note, width = buttonwidth, height = buttonheight)
        self.notebbutton.grid(row = 12, column = 1, columnspan=1, padx = 1, pady = 1, sticky = tk.W+tk.N+tk.S+tk.E)
        
        # ---------------------------------------------------------------------
        # The Change Directory button
        
        self.dir_path = os.path.dirname(os.path.realpath(__file__))
        self.dir_path = self.dir_path + "/DATA"
        if not os.path.exists(self.dir_path):
            os.makedirs(self.dir_path)
            
        self.dirbutton = tk.Button(bottomframe,text="CHANGE DIRECTORY",font=("bold",buttonfont),
                                     command=self.changedir, width = buttonwidth, height = buttonheight)
        self.dirbutton.grid(row = 1, column = 1, columnspan=2, padx = 1, pady = 1, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The plot window
        
        self.canvas = FigureCanvasTkAgg(fig, topframe)
        self.canvas.draw()
        self.canvas.get_tk_widget().pack(side=tk.LEFT, fill= tk.BOTH, expand=True, anchor = tk.NW)
        
        self.toolbar = NavigationToolbar2TkAgg(self.canvas,topframe)
        self.toolbar.update()
        self.canvas._tkcanvas.pack(side=tk.BOTTOM, fill=tk.BOTH, expand=True)

        # ---------------------------------------------------------------------
        # The added mass selection box
        
        self.label_4=tk.Label(bottomframe,text="Added Mass:",font=("bold",buttonfont))
        self.label_4.grid(row = 6, column = 1, sticky = tk.W, padx = padxgen, pady = padygen)
        self.c=tk.StringVar()
        self.droplist=tk.OptionMenu(bottomframe,self.c,*list1)
        self.c.set('Select your Mass')
        self.droplist.grid(row = 6, column = 2, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
        
        # ---------------------------------------------------------------------
        # The operator name text entry box
        
        self.labelentry = tk.Label(bottomframe, text="Operator Name:",font=("bold", buttonfont))
        self.entry_1 = tk.Entry(bottomframe)
        self.labelentry.grid(row = 5, column = 1, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_1.grid(row = 5, column = 2, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
            
        # ---------------------------------------------------------------------
        # The specimen width text entry box
        
        self.labelentry2 = tk.Label(bottomframe, text="Specimen Width (mm):",font=("bold", buttonfont))
        self.entry_2 = tk.Entry(bottomframe)
        self.labelentry2.grid(row = 8, column = 1, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_2.grid(row = 8, column = 2, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
            
        # ---------------------------------------------------------------------
        # The Specimen material text entry box
        
        self.labelentry3 = tk.Label(bottomframe, text="Specimen Material:",font=("bold", buttonfont))
        self.entry_3 = tk.Entry(bottomframe)
        self.labelentry3.grid(row = 7, column = 1, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_3.grid(row = 7, column = 2, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
            
        # ---------------------------------------------------------------------
        # The operator note text entry box
        
#        self.labelentry4 = tk.Label(bottomframe, text="Operator Note:",font=("bold", buttonfont))
        self.entry_4 = ScrolledText(bottomframe, height = 5, width = 15)
#        self.labelentry4.grid(row = 12, column = 1, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_4.grid(row = 12, column = 2, rowspan=1, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
            
        # ---------------------------------------------------------------------
        # The text file name text entry box
        
        self.labelentry5 = tk.Label(bottomframe, text="Text File Name:",font=("bold", buttonfont))
        self.entry_5 = tk.Entry(bottomframe)
        self.labelentry5.grid(row = 4, column = 1, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_5.grid(row = 4, column = 2, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
         
        # ---------------------------------------------------------------------
        # The specimen depth text entry box
        
        self.labelentry6 = tk.Label(bottomframe, text="Specimen Depth (mm):",font=("bold", buttonfont))
        self.entry_6 = tk.Entry(bottomframe)
        self.labelentry6.grid(row = 9, column = 1, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_6.grid(row = 9, column = 2, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
         
        # ---------------------------------------------------------------------
        # The After experiment label separator
#        self.labelentry7 = tk.Label(bottomframe, text="After Experiment:",font=("bold", buttonfont+3))
#        self.labelentry7.grid(row = 11, column = 1, sticky = tk.W, padx = padxgen, pady = padygen)
        
def main():
    """The main set up of the application window.
    - Opens the arduino port
    - Starts the tkinter app
    - Starts the plot animation
    - Create a window at the center of the screen

    Args:
        
    Returns:
    """
    
    comport = "/dev/ttyACM0"
    bd = 250000
    if os.path.isfile("DATA.txt"):
        pass
    elif not os.path.isfile("DATA.txt"):
        dataini = open("DATA.txt","w")
        dataini.write("0,0,0,0")
        dataini.close()
    try:
        ser = serial.Serial(comport, bd)
    except:
        serial.Serial(comport, bd).close()
        ser = serial.Serial(comport, bd)
#        ser = 1
    root = tk.Tk()
    root.title("IZOD")
    #root.iconbitmap('@logo.ico')
    w = 780
    h = 390
    ws = root.winfo_screenwidth()
    hs = root.winfo_screenheight()
    x = (ws/2) - (w/2)
    y = (hs/2) - (h/2)
    root.geometry('%dx%d+%d+%d' % (w, h, x, y))
    app = App(root,ser)
    fig.canvas.mpl_connect('button_press_event', onClick)
    ani = animation.FuncAnimation(fig, animate, interval = 1000)
    root.attributes("-fullscreen", True)
    root.mainloop()
    
    
 
if __name__ == '__main__':
    main()
