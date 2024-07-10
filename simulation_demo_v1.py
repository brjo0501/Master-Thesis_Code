from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.anchorlayout import AnchorLayout
from kivy.uix.checkbox import CheckBox
from kivy.uix.spinner import Spinner
from kivy.uix.label import Label
from kivy.uix.button import Button
from kivy_garden.matplotlib.backend_kivyagg import FigureCanvasKivyAgg
from kivy.graphics import Color, Rectangle
from kivy.clock import Clock
from kivy.core.window import Window
import math
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
from scipy.interpolate import make_interp_spline
from coppeliasim_zmqremoteapi_client import RemoteAPIClient
import pandas as pd
import os
import time
import datetime
from kivy.metrics import dp

def draw_save(G,pos,node_colors,file_name:str, inter_type:str):
    # Draw the graph
    plt.figure(figsize=(12, 10))
    plt.xlim((-12,14))
    plt.ylim((-12,8))
    plt.title(f'Causal Graph: {inter_type}', fontsize=12)
    nx.draw(G, pos,with_labels=True,node_size=2000, node_color=[node_colors[node] for node in G.nodes()], font_size=6, arrowsize=8,width=0.5)
    plt.savefig(file_name)
    nx.write_gml(G, f'{file_name[:-4]}.gml')

class WhiteBoxLayout(BoxLayout):
    def __init__(self, **kwargs):
        super(WhiteBoxLayout, self).__init__(**kwargs)
        with self.canvas.before:
            Color(1, 1, 1, 1)  # Set color to white
            self.rect = Rectangle(size=self.size, pos=self.pos)
        self.bind(size=self._update_rect, pos=self._update_rect)

    def _update_rect(self, instance, value):
        self.rect.size = instance.size
        self.rect.pos = instance.pos

class WhiteGridLayout(GridLayout):
    def __init__(self, **kwargs):
        super(WhiteGridLayout, self).__init__(**kwargs)
        with self.canvas.before:
            Color(1, 1, 1, 1)  # Set color to white
            self.rect = Rectangle(size=self.size, pos=self.pos)
        self.bind(size=self._update_rect, pos=self._update_rect)

    def _update_rect(self, instance, value):
        self.rect.size = instance.size
        self.rect.pos = instance.pos

class CloseBoxLayout(BoxLayout):
    def __init__(self, **kwargs):
        super(CloseBoxLayout, self).__init__(**kwargs)
        self.padding = [0, 0, 0, 0]
        self.spacing = 0


class CloseGridLayout(GridLayout):
    def __init__(self, **kwargs):
        super(CloseGridLayout, self).__init__(**kwargs)
        self.spacing = [0,0]
        self.padding = [0, 0, 0, 0]

class MainLayout(WhiteBoxLayout):
    def __init__(self, **kwargs):
        super(MainLayout, self).__init__(**kwargs)
        Window.title = "Root Cause Analysis Demo - Pick and Place"
        self.orientation = 'horizontal'

        self.anomaly_detected = False

        client = RemoteAPIClient()

        self.sim = client.require('sim')
        self.simBWF = client.require('simBWF')

        inter_script = self.sim.getObject('/Interventions')

        self.camera_1 = self.sim.getObject('/camera_1/camera')
        self.camera_2 = self.sim.getObject('/camera_2/camera')
        self.camera_3 = self.sim.getObject('/camera_3/camera')
        self.camera_EoL = self.sim.getObject('/camera_EoL/camera')

        self.conveyor1 = self.sim.getObject('/genericConveyorTypeA[0]')
        self.conveyor2 = self.sim.getObject('/genericConveyorTypeA[2]')
        self.conveyor3 = self.sim.getObject('/genericConveyorTypeA[1]')

        self.rob_1 = self.sim.getObject('/Ragnar[0]')
        self.rob_2 = self.sim.getObject('/Ragnar[1]')

        self.events = self.sim.getObject('/Events')

        self.inter = {'Gripper 1':'interGripper1','Gripper 2':'interGripper2'}

        # Left Panel for 6 Graphs
        self.left_panel = WhiteGridLayout(cols=1, size_hint_x=0.5)

        self.t_data = pd.DataFrame()  # Time array
        self.y_data = pd.DataFrame()  # Data array
        self.graphs = []
        self.scores = []
        
        # Right Panel for Button, Select Box, and NetworkX Graph
        right_panel = WhiteBoxLayout(orientation='vertical', size_hint_x=0.5)
        box_layout = CloseBoxLayout(orientation='vertical',size_hint_y=0.30)
        center_layout = AnchorLayout(anchor_x='center', anchor_y='center')

        # Button
        self.button1 = Button(text="Start Simulation", size_hint=(None, None), size=(400, 60), background_color=(0.9, 0.9, 0.9, 1))
        center_layout.add_widget(self.button1)
        box_layout.add_widget(center_layout)
        center_layout = AnchorLayout(anchor_x='center', anchor_y='center')

        self.button2 = Button(text="Stop Simulation", size_hint=(None, None), size=(400, 60), background_color=(0.9, 0.9, 0.9, 1))
        center_layout.add_widget(self.button2)
        box_layout.add_widget(center_layout)
        center_layout = AnchorLayout(anchor_x='center', anchor_y='center')

        # Select Box (Spinner)
        self.spinner1 = Spinner(
            text='Select Process Step',
            values=('Robot 1', 'Robot 2', 'Camera 1', 'Camera 2', 'Camera 3', 'Camera EoL'),
            size_hint=(None, None),
            size=(400, 60),
            background_color=(0.5, 0.5, 0.5, 1)
        )
        center_layout.add_widget(self.spinner1)
        box_layout.add_widget(center_layout)
        center_layout = AnchorLayout(anchor_x='center', anchor_y='center')

        self.spinner2 = Spinner(
            text='Select Intervention',
            values=('Gripper 1', 'Gripper 2'),
            size_hint=(None, None),
            size=(400, 60),
            background_color=(0.5, 0.5, 0.5, 1)
        )
        center_layout.add_widget(self.spinner2)
        box_layout.add_widget(center_layout)
        right_panel.add_widget(box_layout)

        box_layout1 = CloseBoxLayout(orientation='vertical',size_hint_y=0.30)

        fig, ax = plt.subplots(figsize=(4, 3))
        ax.set_facecolor('#f0f8ff')
        ax.set_title(f'Score')
        ax.set_xlabel('Time')
        ax.set_ylabel('Value')
        self.canvas_score = FigureCanvasKivyAgg(fig)
        box_layout1.add_widget(self.canvas_score)
        right_panel.add_widget(box_layout1)

        box_layout2 = CloseBoxLayout(orientation='vertical')
    
        # NetworkX Graph Display
        self.networkx_graph_display = FigureCanvasKivyAgg(plt.figure())

        box_layout2.add_widget(self.networkx_graph_display)
        right_panel.add_widget(box_layout2)

        self.networkx_graph_display.figure = self.create_networkx_graph()
        self.networkx_graph_display.draw()

        self.button1.bind(on_press=self.start_sim)
        self.button2.bind(on_press=self.stop_sim)
        
        self.spinner1.bind(text=self.on_spinner_select_1)
        self.spinner2.bind(text=self.on_spinner_select_2)

        self.add_widget(self.left_panel)
        self.add_widget(right_panel)

    def create_networkx_graph(self):
        G = nx.DiGraph()
        fig, ax = plt.subplots(figsize=(12, 10))
        ax.set_facecolor('#f0f8ff')  # Very light blue background
        # Draw the graph
        nodes = [
        'cam_1_X', 'cam_2_X', 'cam_3_X',
        'cam_1_Y', 'cam_2_Y', 'cam_3_Y',
        'EoL_1_X', 'EoL_2_X', 'EoL_3_X', 'EoL_4_X', 'EoL_5_X', 'EoL_6_X',
        'EoL_1_Y', 'EoL_2_Y', 'EoL_3_Y', 'EoL_4_Y', 'EoL_5_Y', 'EoL_6_Y',
        'rob_1_1', 'rob_1_2', 'rob_1_3', 'rob_1_4', 'rob_1_maxVel',
        'rob_2_1', 'rob_2_2', 'rob_2_3', 'rob_2_4', 'rob_2_maxVel',
        'rob_1_supply', 'rob_2_supply',
        'rob_1_vacuum', 'rob_2_vacuum',
        'con_1','con_2','con_3',
        'score']

        edges = [   
        ('cam_1_X', 'rob_2_1'), ('cam_1_Y', 'rob_2_1'),
        ('cam_1_X', 'rob_2_2'), ('cam_1_Y', 'rob_2_2'),
        ('cam_1_X', 'rob_2_3'), ('cam_1_Y', 'rob_2_3'),
        ('cam_1_X', 'rob_2_4'), ('cam_1_Y', 'rob_2_4'),
        
        ('cam_2_X', 'rob_1_1'), ('cam_2_Y', 'rob_1_1'),
        ('cam_2_X', 'rob_1_2'), ('cam_2_Y', 'rob_1_2'),
        ('cam_2_X', 'rob_1_3'), ('cam_2_Y', 'rob_1_3'),
        ('cam_2_X', 'rob_1_4'), ('cam_2_Y', 'rob_1_4'),
        
        ('cam_3_X', 'rob_1_1'), ('cam_3_Y', 'rob_1_1'),
        ('cam_3_X', 'rob_1_2'), ('cam_3_Y', 'rob_1_2'),
        ('cam_3_X', 'rob_1_3'), ('cam_3_Y', 'rob_1_3'),
        ('cam_3_X', 'rob_1_4'), ('cam_3_Y', 'rob_1_4'),
        
        ('rob_1_maxVel', 'rob_1_1'), ('rob_1_maxVel', 'rob_1_2'),
        ('rob_1_maxVel', 'rob_1_3'), ('rob_1_maxVel', 'rob_1_4'),
        
        ('rob_2_maxVel', 'rob_2_1'), ('rob_2_maxVel', 'rob_2_2'),
        ('rob_2_maxVel', 'rob_2_3'), ('rob_2_maxVel', 'rob_2_4'),
        
        ('con_2', 'rob_1_1'), ('con_2', 'rob_1_2'), ('con_2', 'rob_1_3'), ('con_2', 'rob_1_4'),
        ('con_3', 'rob_1_1'), ('con_3', 'rob_1_2'), ('con_3', 'rob_1_3'), ('con_3', 'rob_1_4'),

        ('con_2', 'rob_2_1'), ('con_2', 'rob_2_2'), ('con_2', 'rob_2_3'), ('con_2', 'rob_2_4'),
        ('con_1', 'rob_2_1'), ('con_1', 'rob_2_2'), ('con_1', 'rob_2_3'), ('con_1', 'rob_2_4'),

        ('con_2', 'EoL_1_X'), ('con_2', 'EoL_1_Y'),
        
        ('rob_1_1', 'rob_2_1'), ('rob_1_1', 'rob_2_2'), ('rob_1_1', 'rob_2_3'), ('rob_1_1', 'rob_2_4'),
        ('rob_1_2', 'rob_2_1'), ('rob_1_2', 'rob_2_2'), ('rob_1_2', 'rob_2_3'), ('rob_1_2', 'rob_2_4'),
        ('rob_1_3', 'rob_2_1'), ('rob_1_3', 'rob_2_2'), ('rob_1_3', 'rob_2_3'), ('rob_1_3', 'rob_2_4'),
        ('rob_1_4', 'rob_2_1'), ('rob_1_4', 'rob_2_2'), ('rob_1_4', 'rob_2_3'), ('rob_1_4', 'rob_2_4'),

        ('rob_1_supply', 'rob_1_vacuum'), 
        ('rob_2_supply', 'rob_2_vacuum'),

        
        ('rob_1_vacuum', 'rob_2_1'), ('rob_1_vacuum', 'rob_2_2'),
        ('rob_1_vacuum', 'rob_2_3'), ('rob_1_vacuum', 'rob_2_4'),

        ('rob_1_1', 'EoL_2_X'), ('rob_1_2', 'EoL_2_X'),
        ('rob_1_3', 'EoL_2_X'), ('rob_1_4', 'EoL_2_X'),
        ('rob_1_1', 'EoL_2_Y'), ('rob_1_2', 'EoL_2_Y'),
        ('rob_1_3', 'EoL_2_Y'), ('rob_1_4', 'EoL_2_Y'),
        
        ('rob_2_1', 'EoL_3_X'), ('rob_2_2', 'EoL_3_X'),
        ('rob_2_3', 'EoL_3_X'), ('rob_2_4', 'EoL_3_X'),
        ('rob_2_1', 'EoL_3_Y'), ('rob_2_2', 'EoL_3_Y'),
        ('rob_2_3', 'EoL_3_Y'), ('rob_2_4', 'EoL_3_Y'),
        
        ('rob_2_1', 'EoL_4_X'), ('rob_2_2', 'EoL_4_X'),
        ('rob_2_3', 'EoL_4_X'), ('rob_2_4', 'EoL_4_X'),
        ('rob_2_1', 'EoL_4_Y'), ('rob_2_2', 'EoL_4_Y'),
        ('rob_2_3', 'EoL_4_Y'), ('rob_2_4', 'EoL_4_Y'),
        
        ('rob_2_1', 'EoL_5_X'), ('rob_2_2', 'EoL_5_X'),
        ('rob_2_3', 'EoL_5_X'), ('rob_2_4', 'EoL_5_X'),
        ('rob_2_1', 'EoL_5_Y'), ('rob_2_2', 'EoL_5_Y'),
        ('rob_2_3', 'EoL_5_Y'), ('rob_2_4', 'EoL_5_Y'),

        ('rob_2_1', 'EoL_6_X'), ('rob_2_2', 'EoL_6_X'),
        ('rob_2_3', 'EoL_6_X'), ('rob_2_4', 'EoL_6_X'),
        ('rob_2_1', 'EoL_6_Y'), ('rob_2_2', 'EoL_6_Y'),
        ('rob_2_3', 'EoL_6_Y'), ('rob_2_4', 'EoL_6_Y'),

        ('rob_1_vacuum', 'EoL_2_X'), ('rob_1_vacuum', 'EoL_2_Y'),
        
        ('rob_2_vacuum', 'EoL_3_X'), ('rob_2_vacuum', 'EoL_3_Y'),
        ('rob_2_vacuum', 'EoL_4_X'), ('rob_2_vacuum', 'EoL_4_Y'),
        ('rob_2_vacuum', 'EoL_5_X'), ('rob_2_vacuum', 'EoL_5_Y'),
        ('rob_2_vacuum', 'EoL_6_X'), ('rob_2_vacuum', 'EoL_6_Y'),

        ('EoL_1_X','score'), ('EoL_2_X','score'), ('EoL_3_X','score'), ('EoL_4_X','score'), ('EoL_5_X','score'), ('EoL_6_X','score'),
        ('EoL_1_Y','score'), ('EoL_2_Y','score'), ('EoL_3_Y','score'), ('EoL_4_Y','score'), ('EoL_5_Y','score'), ('EoL_6_Y','score')]

        pos = {
        'cam_1_X':(8,4), 'cam_2_X':(-9,6), 'cam_3_X':(-5,6),
        'cam_1_Y':(8,2), 'cam_2_Y':(-7,6), 'cam_3_Y':(-3,6),
        'EoL_1_X':(10,-8), 'EoL_2_X':(-10,-8), 'EoL_3_X':(-6,-8), 'EoL_4_X':(-2,-8), 'EoL_5_X':(2,-8), 'EoL_6_X':(6,-8),
        'EoL_1_Y':(12,-8), 'EoL_2_Y':(-8,-8), 'EoL_3_Y':(-4,-8), 'EoL_4_Y':(0,-8), 'EoL_5_Y':(4,-8), 'EoL_6_Y':(8,-8),
        'score':(0,-10),
        'rob_2_1':(-6,-4), 'rob_2_2':(-4,-4), 'rob_2_3':(-2,-4), 'rob_2_4':(-0,-4), 'rob_2_maxVel':(2,-4),
        'rob_1_1':(-9,1), 'rob_1_2':(-7,1), 'rob_1_3':(-5,1), 'rob_1_4':(-3,1), 'rob_1_maxVel':(-1,1),
        'rob_1_vacuum':(2,1), 'rob_2_vacuum':(5,-4),'rob_1_supply':(5,1), 'rob_2_supply':(8,-4),
        'con_1':(8,-1),'con_2':(8,6),'con_3':(3,6)}

        colors = {
        'cam_1_X':'skyblue', 'cam_2_X':'skyblue', 'cam_3_X':'skyblue',
        'cam_1_Y':'skyblue', 'cam_2_Y':'skyblue', 'cam_3_Y':'skyblue',
        'EoL_1_X':'lightgreen', 'EoL_2_X':'lightgreen', 'EoL_3_X':'lightgreen', 'EoL_4_X':'lightgreen', 'EoL_5_X':'lightgreen', 'EoL_6_X':'lightgreen',
        'EoL_1_Y':'lightgreen', 'EoL_2_Y':'lightgreen', 'EoL_3_Y':'lightgreen', 'EoL_4_Y':'lightgreen', 'EoL_5_Y':'lightgreen', 'EoL_6_Y':'lightgreen',
        'score':'lightsalmon',
        'rob_1_1':'tan', 'rob_1_2':'tan', 'rob_1_3':'tan', 'rob_1_4':'tan', 'rob_1_maxVel':'tan',
        'rob_2_1':'tan', 'rob_2_2':'tan', 'rob_2_3':'tan', 'rob_2_4':'tan', 'rob_2_maxVel':'tan',
        'rob_1_vacuum':'tan', 'rob_2_vacuum':'tan','rob_1_supply':'tan', 'rob_2_supply':'tan',
        'con_1':'lightgrey','con_2':'lightgrey','con_3':'lightgrey'}

        G.add_nodes_from(nodes)
        G.add_edges_from(edges)
        ax.set_xlim(-12,14)
        ax.set_ylim(-12,8)
        ax.set_title(f'Causal Graph:', fontsize=12)
        nx.draw(G, pos,with_labels=True,node_size=1500, node_color=[colors[node] for node in G.nodes()], font_size=6, arrowsize=8,width=0.5)
        return fig

    def on_button_press(self, instance):
        # Toggle the display of the NetworkX graph
        if self.networkx_graph_display.figure.gca().has_data():
            self.networkx_graph_display.figure = plt.figure()
        else:
            self.networkx_graph_display.figure = self.create_networkx_graph()
        self.networkx_graph_display.draw()
    
    def stop_sim(self, instance):
        self.sim.stopSimulation()
        # Clear the figures when stopping the simulation
        for canvas in self.graphs:
            ax = canvas.figure.gca()  # Get the current axes
            ax.cla()  # Clear the current axes
            canvas.draw()
        
        self.t_data = pd.DataFrame()  # Time array
        self.y_data = pd.DataFrame()  # Data array

        #self.sim.setBoolParam(self.sim.boolparam_display_enabled, True)
    
    def start_sim(self, instance):
        self.sim.startSimulation()
        self.sim.setBoolParam(self.sim.boolparam_display_enabled, False)
        print('Connection and Start Simulation')
        # Schedule update every second
        self.update_interval = 0.1  # Update interval in seconds
        self.time_elapsed = 0.0  # Time elapsed in seconds
        Clock.schedule_interval(self.update_plots, self.update_interval)

    def on_spinner_select_1(self, spinner, text):
        
        for canvas in self.graphs:
            ax = canvas.figure.gca()  # Get the current axes
            ax.cla()  # Clear the current axes
            canvas.draw()

        num_graphs = len(self.graphs)

        if text == 'Robot 1':
            self.graph_count = 7
            self.object = self.rob_1
        elif text == 'Robot 2':
            self.graph_count = 7
            self.object = self.rob_2
        elif text == 'Camera 1':
            self.graph_count = 2
            self.object = self.camera_1
        elif text == 'Camera 2':
            self.graph_count = 2
            self.object = self.camera_2
        elif text == 'Camera 3':
            self.graph_count = 2
            self.object = self.camera_3,
        elif text == 'Camera EoL':
            self.graph_count = 12
            self.object = self.camera_EoL

        if self.graph_count > num_graphs:
            for i in range(self.graph_count-num_graphs):
                self.add_graph()
        elif self.graph_count < num_graphs:
            for i in range(num_graphs-self.graph_count):
                self.remove_graph()

    def add_graph(self):
        # Create a new figure and add it to the layout
        fig, ax = plt.subplots()
        ax.set_facecolor('#f0f8ff')
        canvas = FigureCanvasKivyAgg(fig)
        self.left_panel.add_widget(canvas)
        self.graphs.append(canvas)

    def remove_graph(self):
        # Remove the last added graph
        if self.graphs:
            graph_to_remove = self.graphs.pop()
            self.left_panel.remove_widget(graph_to_remove)

    def on_spinner_select_2(self, spinner, text):
        # Placeholder for updating graphs based on spinner selection
        print(f"Selected: {text}")
    
    def select_columns(self,data):
        if self.object == self.camera_1:
            data = data[['sizeX','sizeY']]
            data = data.rename(columns={'sizeX': 'cam_1_X','sizeY': 'cam_1_Y'})
        elif self.object == self.camera_2:
            data = data[['sizeX','sizeY']]
            data = data.rename(columns={'sizeX': 'cam_2_X','sizeY': 'cam_2_Y'})
        elif self.object == self.camera_3:
            data = data[['sizeX','sizeY']]
            data = data.rename(columns={'sizeX': 'cam_3_X','sizeY': 'cam_3_Y'})
        elif self.object == self.camera_EoL:
            data = data[['part1SizeX','part2SizeX','part3SizeX','part4SizeX',
                        'part1SizeY','part2SizeY','part3SizeY','part4SizeY',
                        'tray1SizeX','tray1SizeY','tray2SizeX','tray2SizeY']]
            data = data.rename(columns={'part1SizeX':'EoL_3_X','part2SizeX':'EoL_4_X','part3SizeX':'EoL_5_X','part4SizeX':'EoL_6_X',
                                        'part1SizeY':'EoL_3_Y','part2SizeY':'EoL_4_Y','part3SizeY':'EoL_5_Y', 'part4SizeY':'EoL_6_Y',
                                        'tray1SizeX':'EoL_1_X','tray1SizeY':'EoL_1_Y',
                                        'tray2SizeX':'EoL_2_X','tray2SizeY':'EoL_2_Y'})
        elif self.object == self.rob_1:
            data = data[['jointVelo1','jointVelo2', 'jointVelo4',	'maxVel','gripperSupply','gripperVacuum','jointVelo3']]
            data = data.rename(columns={'jointVelo1':'rob_1_1','jointVelo2':'rob_1_2','jointVelo3':'rob_1_3','jointVelo4':'rob_1_4',
                                        'maxVel':'rob_1_maxVel','gripperSupply':'rob_1_supply','gripperVacuum':'rob_1_vacuum'})
        elif self.object == self.rob_2:
            data = data[['jointVelo1','jointVelo2', 'jointVelo4',	'maxVel','gripperSupply','gripperVacuum','jointVelo3']]
            data = data.rename(columns={'jointVelo1':'rob_2_1','jointVelo2':'rob_2_2','jointVelo3':'rob_2_3','jointVelo4':'rob_2_4',
                                        'maxVel':'rob_2_maxVel','gripperSupply':'rob_2_supply','gripperVacuum':'rob_2_vacuum'})
        return data
    
    def select_columns_EoL(self,data):
        data = data[['part1SizeX','part2SizeX','part3SizeX','part4SizeX',
                    'part1SizeY','part2SizeY','part3SizeY','part4SizeY',
                    'tray1SizeX','tray1SizeY','tray2SizeX','tray2SizeY']]
        data = data.rename(columns={'part1SizeX':'EoL_3_X','part2SizeX':'EoL_4_X','part3SizeX':'EoL_5_X','part4SizeX':'EoL_6_X',
                                    'part1SizeY':'EoL_3_Y','part2SizeY':'EoL_4_Y','part3SizeY':'EoL_5_Y', 'part4SizeY':'EoL_6_Y',
                                    'tray1SizeX':'EoL_1_X','tray1SizeY':'EoL_1_Y',
                                    'tray2SizeX':'EoL_2_X','tray2SizeY':'EoL_2_Y'})
        return data

    def update_plots(self, dt):
        if self.sim.getSimulationTime() > 0:
            self.time_elapsed += self.update_interval
            i = 0
            obj_data = pd.DataFrame([self.sim.unpackTable(self.sim.readCustomDataBlock(self.object,'customData'))])
            data = self.select_columns(obj_data)
            self.t_data = pd.concat([self.t_data,pd.DataFrame({'time': [self.sim.getSimulationTime()]})], ignore_index=True)
            self.y_data = pd.concat([self.y_data,data], ignore_index=True) # Example: Random data point

            for canvas in self.graphs:
                fig = canvas.figure
                column = data.columns[i]
                ax = fig.axes[0]  # Assuming only one subplot per figure

                if self.sim.getSimulationTime() > 10: 
                    t_end = self.t_data['time'].iloc[-1]
                    t_start = t_end-10
                    ax.set_xlim(t_start,t_end)

                # Update plot with new data
                ax.plot(self.t_data['time'], self.y_data[column])

                # Adjust plot limits if needed (optional)
                ax.relim()
                ax.autoscale_view()

                ax.set_title(f'Data:{column}')
                ax.set_xlabel('Time')
                ax.set_ylabel('Value')
                # Redraw canvas to reflect updated plot
                canvas.draw()
                i +=1

            obj_EoL = pd.DataFrame([self.sim.unpackTable(self.sim.readCustomDataBlock(self.camera_EoL,'customData'))])
            data_EoL = self.select_columns_EoL(obj_EoL)

            EoL_nodes = ['EoL_1_X', 'EoL_1_Y',
                    'EoL_2_X', 'EoL_2_Y',
                    'EoL_3_X', 'EoL_3_Y',
                    'EoL_4_X', 'EoL_4_Y',
                    'EoL_5_X','EoL_5_Y',
                    'EoL_6_X', 'EoL_6_Y']
            
            for index, row in data_EoL.iterrows():
                non_zero_count = (row != 0).sum()
                total_count = len(EoL_nodes)
                score = (non_zero_count / total_count) * 100
                self.scores.append(score)
            
            fig_score = self.canvas_score.figure
            ax_score = fig_score.axes[0]

            if self.sim.getSimulationTime() > 10: 
                t_end = self.t_data['time'].iloc[-1]
                t_start = t_end-10
                ax_score.set_xlim(t_start,t_end)

            ax_score.plot(self.t_data['time'], self.scores)
            self.canvas_score.draw()
            
class MyApp(App):
    def build(self):
        return MainLayout()

if __name__ == '__main__':
    MyApp().run()
