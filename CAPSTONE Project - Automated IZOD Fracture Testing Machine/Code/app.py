# -*- coding: utf-8 -*-
import glob
import Communication as cm
import serial
import tkinter as tk
import numpy as np
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
        
        f = open(self.moveto, "r", encoding="UTF8").readlines()
        f.insert(3,"\n")
        opnote = "Operator Notes:\t" + self.entry_4.get(1.0,tk.END)
        f.insert(4,opnote)
        fwrite = open(self.moveto, "w", encoding="UTF8")
        for i in range(0,len(f)):
            fwrite.write(f[i])
        fwrite.close()
        fwrite2 = open(self.moveto, "r", encoding="UTF8").read()
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
        Fc = open("preferences.txt", "r", encoding="UTF8")
        readlines = Fc.readlines()
        testread = [line.split("\t") for line in readlines]
        Fc.close()
        self.count = int(testread[0][1])-1
        Fread = glob.glob('IZOD'+str(self.count) + '*.txt')
        self.Fileread = Fread[0]
        f = open(self.Fileread, "r", encoding="UTF8").readlines()
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
        
        fData = open("DATA.txt","r", encoding="UTF8").read()
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
        
        fwrite = open(self.Fileread, "w", encoding="UTF8")
        for i in range(0,len(f)):
            fwrite.write(f[i])
        fwrite.close()
        fwrite2 = open(self.Fileread, "r", encoding="UTF8").read()
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
        master.protocol('WM_DELETE_WINDOW', lambda master=master:self._quit(master))
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
        buttonheight = 2
        buttonfont = 10
        titlefont = 20
        padxgen = 5
        padygen = 5
        padxbut = 1
        padybut = 1
        titleframe = tk.Frame(master, borderwidth=3, relief = tk.RIDGE)
        titleframe.pack(fill=tk.BOTH, side=tk.TOP)
        topframe = tk.Frame(master, borderwidth=3, relief = tk.RIDGE)
        topframe.pack(fill=tk.BOTH,expand = True, side=tk.TOP)
        bottomframe = tk.Frame(master, borderwidth=3, relief = tk.RIDGE)
        bottomframe.pack(fill=tk.BOTH, side=tk.LEFT, expand = True)
        bottomframe2 = tk.Frame(master, borderwidth=3, relief = tk.RIDGE)
        bottomframe2.pack(fill=tk.BOTH, side=tk.LEFT, expand = True)
        
        bottomframe.grid_rowconfigure(0, weight=1)
        bottomframe.grid_rowconfigure(4, weight=1)
        bottomframe.grid_columnconfigure(0, weight=1)
        bottomframe2.grid_rowconfigure(3, weight=1)
        bottomframe2.grid_columnconfigure(3, weight=1)
        
        
        try:
            Fread = glob.glob('DATA\\IZOD'+str(self.count) + '*.txt')
            self.Fileread = Fread[0]
        except:
            f = """Waiting for DATA..."""
        
        # ---------------------------------------------------------------------
        #  The output text box
        try:
            f = open(self.Fileread, "r").read()
        except: pass

        self.scroll = tk.Scrollbar(topframe)
        self.T = tk.Text(topframe, height = 10, width = int(master.winfo_width()/4))
        self.scroll.pack(side = tk.RIGHT, fill = tk.Y)
        self.T.pack(side = tk.RIGHT,fill = tk.BOTH, expand = False, padx = padxgen)
        self.scroll.config(command = self.T.yview)
        self.T.config(yscrollcommand = self.scroll.set)
        self.T.insert(tk.END, f)

        # ---------------------------------------------------------------------
        # The quit button
        
        self.quitbutton = tk.Button(bottomframe, 
                             text="QUIT", fg="red",font=("bold",buttonfont),
                             command=lambda master=master:self._quit(master), width = buttonwidth, height = buttonheight)
        self.quitbutton.grid(row = 1, columnspan = 1, rowspan=1, column = 1, padx = padxbut, pady = padybut, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The run button
        
        self.runbutton = tk.Button(bottomframe,text="RUN",font=("bold",buttonfont),
                                   command=self.write_record, width = buttonwidth, height = buttonheight)
        self.runbutton.grid(row = 1, columnspan = 1, rowspan=1, column = 2, padx = padxbut, pady = padybut, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The loading button
        
        self.clearbutton = tk.Button(bottomframe, 
                             text="LOADING",font=("bold",buttonfont),
                             command=self.loading_hammer, width = buttonwidth, height = buttonheight)
        self.clearbutton.grid(row = 2, column = 1, padx = padxbut, pady = padybut, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The reset button
        
        self.resetbutton = tk.Button(bottomframe,text="RESET",font=("bold",buttonfont),
                                     command=self.reset_hammer, width = buttonwidth, height = buttonheight)
        self.resetbutton.grid(row = 2, column = 2, padx = padxbut, pady = padybut, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The calibration button
        
        self.calibbutton = tk.Button(bottomframe,text="CALIBRATION", fg="green",font=("bold",buttonfont),
                                     command=self.calibration, width = buttonwidth, height = buttonheight)
        self.calibbutton.grid(row = 3, column = 1, columnspan=2, padx = padxbut, pady = padybut, sticky = tk.W+tk.E+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The operator note button
        
        self.notebbutton = tk.Button(bottomframe2,text="Print", fg="black",font=("bold",buttonfont),
                                     command=self.note, width = buttonwidth, height = buttonheight)
        self.notebbutton.grid(row = 1, column = 2, columnspan=1, padx = padxbut, pady = padybut+1, sticky = tk.W+tk.N+tk.S)
        
        # ---------------------------------------------------------------------
        # The plot window
        
        self.canvas = FigureCanvasTkAgg(fig, topframe)
        self.canvas.draw()
        self.canvas.get_tk_widget().pack(side=tk.LEFT, fill= tk.BOTH, expand=True, anchor = tk.NW)
        
        self.toolbar = NavigationToolbar2TkAgg(self.canvas,topframe)
        self.toolbar.update()
        self.canvas._tkcanvas.pack(side=tk.TOP, fill=tk.BOTH, expand=True)

        # ---------------------------------------------------------------------
        # The added mass selection box
        
        self.label_4=tk.Label(bottomframe,text="Added Mass:",font=("bold",buttonfont))
        self.label_4.grid(row = 3, column = 3, sticky = tk.W, padx = padxgen, pady = padygen)
        self.c=tk.StringVar()
        self.droplist=tk.OptionMenu(bottomframe,self.c,*list1)
        self.c.set('')
        self.droplist.grid(row = 3, column = 4, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
        
        # ---------------------------------------------------------------------
        # The title label
        
        self.labeltitle=tk.Label(titleframe,text="IZOD Fracture Testing Machine",width=30,font=("bold",titlefont))
        self.labeltitle.pack(fill = tk.BOTH)
        
        # ---------------------------------------------------------------------
        # The change directory menu box
        
        self.dir_path = os.path.dirname(os.path.realpath(__file__))
        self.dir_path = self.dir_path + "\DATA"
        if not os.path.exists(self.dir_path):
            os.makedirs(self.dir_path)
    
        self.menu=tk.Menu(master)
        self.filemenu=tk.Menu(self.menu,tearoff = 0)
        self.menu.add_cascade(label="File", menu=self.filemenu)
        self.filemenu.add_command(label="Change Directory",command=self.changedir)
        self.filemenu.add_separator()
        self.filemenu.add_command(label="Exit" , command=lambda master=master:quit(master))
        master.config(menu=self.menu)
        self.menu.config(bg='white',bd=4,relief=tk.RAISED)
            
        # ---------------------------------------------------------------------
        # The operator name text entry box
        
        self.labelentry = tk.Label(bottomframe, text="Operator Name:",font=("bold", buttonfont))
        self.entry_1 = tk.Entry(bottomframe)
        self.labelentry.grid(row = 2, column = 3, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_1.grid(row = 2, column = 4, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
            
        # ---------------------------------------------------------------------
        #  The specimen width text entry box
        
        self.labelentry2 = tk.Label(bottomframe, text="Specimen Width (mm):",font=("bold", buttonfont))
        self.entry_2 = tk.Entry(bottomframe)
        self.labelentry2.grid(row = 2, column = 5, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_2.grid(row = 2, column = 6, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
            
        # ---------------------------------------------------------------------
        # The specimen material text entry box
        
        self.labelentry3 = tk.Label(bottomframe, text="Specimen Material:",font=("bold", buttonfont))
        self.entry_3 = tk.Entry(bottomframe)
        self.labelentry3.grid(row = 1, column = 5, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_3.grid(row = 1, column = 6, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
            
        # ---------------------------------------------------------------------
        # The operator note text entry box
        
        self.labelentry4 = tk.Label(bottomframe2, text="Operator Note:",font=("bold", buttonfont))
        self.entry_4 = ScrolledText(bottomframe2, height = 5, width = 30)
        self.labelentry4.grid(row = 2, column = 1, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_4.grid(row = 2, column = 2, rowspan=1, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
            
        # ---------------------------------------------------------------------
        # The output file name text entry box
        
        self.labelentry5 = tk.Label(bottomframe, text="Text File Name:",font=("bold", buttonfont))
        self.entry_5 = tk.Entry(bottomframe)
        self.labelentry5.grid(row = 1, column = 3, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_5.grid(row = 1, column = 4, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
         
        # ---------------------------------------------------------------------
        # The After experiment label
        
        self.labelentry7 = tk.Label(bottomframe2, text="After Experiment:",font=("bold", buttonfont+3))
        self.labelentry7.grid(row = 1, column = 1, sticky = tk.W, padx = padxgen, pady = padygen)
         
        # ---------------------------------------------------------------------
        # The specimen depth text entry box
        
        self.labelentry6 = tk.Label(bottomframe, text="Specimen Depth (mm):",font=("bold", buttonfont))
        self.entry_6 = tk.Entry(bottomframe)
        self.labelentry6.grid(row = 3, column = 5, sticky = tk.W, padx = padxgen, pady = padygen)
        self.entry_6.grid(row = 3, column = 6, sticky = tk.W+tk.E, padx = padxgen, pady = padygen)
        
def main():
    """The main set up of the application window.
    - Opens the arduino port
    - Starts the tkinter app
    - Starts the plot animation
    - Create a window at the center of the screen

    Args:
        
    Returns:
    """
    
    comport = "com8"
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
#        serial.Serial(comport, bd).close()
#        ser = serial.Serial(comport, bd)
        ser = 1
    root = tk.Tk()
    root.title("IZOD")
    root.iconbitmap('logo.ico')
    w = 1500
    h = 800
    ws = root.winfo_screenwidth()
    hs = root.winfo_screenheight()
    x = (ws/2) - (w/2)
    y = (hs/2) - (h/2)
    root.geometry('%dx%d+%d+%d' % (w, h, x, y))
    app = App(root,ser)
    fig.canvas.mpl_connect('button_press_event', onClick)
    ani = animation.FuncAnimation(fig, animate, interval = 1000)
    root.mainloop()
    
    
 
if __name__ == '__main__':
    main()
