from kivy.core.window import Window
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

import math
import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
from scipy.interpolate import make_interp_spline
from coppeliasim_zmqremoteapi_client import RemoteAPIClient
import pandas as pd
pd.set_option('future.no_silent_downcasting', True)
import os
import time
import datetime
from kivy.metrics import dp

import pyrca

from pyrca.analyzers.ht import HT, HTConfig
from pyrca.analyzers.epsilon_diagnosis import EpsilonDiagnosis, EpsilonDiagnosisConfig
from pyrca.analyzers.bayesian import BayesianNetwork, BayesianNetworkConfig
from pyrca.analyzers.random_walk import RandomWalk, RandomWalkConfig
from pyrca.analyzers.rcd import RCD, RCDConfig

import matplotlib.pyplot as plt
import pandas as pd
import os

from sklearn.exceptions import ConvergenceWarning

import warnings
warnings.filterwarnings("ignore", category=RuntimeWarning)
warnings.filterwarnings("ignore", category=ConvergenceWarning)
warnings.filterwarnings("ignore", category=UserWarning)

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
        #Window.fullscreen = 'auto'
        self.orientation = 'horizontal'

        self.anomaly_detected = False

        self.rca_activated = False

        self.normal_data = pd.DataFrame()
        self.abnormal_data = pd.DataFrame()

        self.client = RemoteAPIClient()

        self.sim = self.client.require('sim')
        self.simBWF = self.client.require('simBWF')

        self.inter_script = self.sim.getObject('/Interventions')

        self.camera_1 = self.sim.getObject('/camera_1/camera')
        self.camera_2 = self.sim.getObject('/camera_2/camera')
        self.camera_3 = self.sim.getObject('/camera_3/camera')
        self.camera_EoL = self.sim.getObject('/camera_EoL/camera')

        self.conveyor_1 = self.sim.getObject('/genericConveyorTypeA[0]')
        self.conveyor_2 = self.sim.getObject('/genericConveyorTypeA[2]')
        self.conveyor_3 = self.sim.getObject('/genericConveyorTypeA[1]')

        self.rob_1 = self.sim.getObject('/Ragnar[0]')
        self.rob_2 = self.sim.getObject('/Ragnar[1]')

        self.objects = [self.camera_1,self.camera_2,self.camera_3,self.conveyor_1,self.conveyor_2,self.conveyor_3,self.rob_1,self.rob_2,self.camera_EoL]

        self.events = self.sim.getObject('/Events')

        self.inter = {'Normal':'normal','Gripper 1':'interGripper1','Gripper 2':'interGripper2'}


        # Left Panel for 6 Graphs
        self.left_panel = WhiteGridLayout(cols=1, size_hint_x=0.5)

        self.t_data = pd.DataFrame()
        self.data_out = pd.DataFrame()
        self.graphs = []
        self.scores = []

        self.colors = {
        'cam_1_X':'skyblue', 'cam_2_X':'skyblue', 'cam_3_X':'skyblue',
        'cam_1_Y':'skyblue', 'cam_2_Y':'skyblue', 'cam_3_Y':'skyblue',
        'EoL_1_X':'lightgreen', 'EoL_2_X':'lightgreen', 'EoL_3_X':'lightgreen', 'EoL_4_X':'lightgreen', 'EoL_5_X':'lightgreen', 'EoL_6_X':'lightgreen',
        'EoL_1_Y':'lightgreen', 'EoL_2_Y':'lightgreen', 'EoL_3_Y':'lightgreen', 'EoL_4_Y':'lightgreen', 'EoL_5_Y':'lightgreen', 'EoL_6_Y':'lightgreen',
        'score':'lightsalmon',
        'rob_1_1':'tan', 'rob_1_2':'tan', 'rob_1_3':'tan', 'rob_1_4':'tan', 'rob_1_maxVel':'tan',
        'rob_2_1':'tan', 'rob_2_2':'tan', 'rob_2_3':'tan', 'rob_2_4':'tan', 'rob_2_maxVel':'tan',
        'rob_1_vacuum':'tan', 'rob_2_vacuum':'tan','rob_1_supply':'tan', 'rob_2_supply':'tan',
        'con_1':'lightgrey','con_2':'lightgrey','con_3':'lightgrey'}
        
        # Right Panel for Button, Select Box, and NetworkX Graph
        right_panel = WhiteBoxLayout(orientation='vertical', size_hint_x=0.5)
        box_layout = CloseBoxLayout(orientation='vertical',size_hint_y=0.30)
        center_layout = AnchorLayout(anchor_x='center', anchor_y='center')

        # Buttons
        self.button1 = Button(text='Start Simulation', size_hint=(None, None), size=(400, 60), background_color=(0.9, 0.9, 0.9, 1))
        center_layout.add_widget(self.button1)
        box_layout.add_widget(center_layout)
        center_layout = AnchorLayout(anchor_x='center', anchor_y='center')

        self.button2 = Button(text='Stop Simulation', size_hint=(None, None), size=(400, 60), background_color=(0.9, 0.9, 0.9, 1))
        center_layout.add_widget(self.button2)
        box_layout.add_widget(center_layout)
        center_layout = AnchorLayout(anchor_x='center', anchor_y='center')

        # self.button3 = Button(text='Pause Simulation', size_hint=(None, None), size=(400, 60), background_color=(0.9, 0.9, 0.9, 1))
        # center_layout.add_widget(self.button3)
        # box_layout.add_widget(center_layout)
        # center_layout = AnchorLayout(anchor_x='center', anchor_y='center')

        # Select Box (Spinner)
        self.spinner1 = Spinner(
            text='Select Process Step',
            values=('Robot 1', 'Robot 2', 'Camera 1', 'Camera 2', 'Camera 3', 'Camera EoL','Conveyor 1','Conveyor 2','Conveyor 3'),
            size_hint=(None, None),
            size=(400, 60),
            background_color=(0.5, 0.5, 0.5, 1)
        )
        center_layout.add_widget(self.spinner1)
        box_layout.add_widget(center_layout)
        center_layout = AnchorLayout(anchor_x='center', anchor_y='center')

        self.spinner2 = Spinner(
            text='Select Intervention',
            values=('Normal','Gripper 1', 'Gripper 2'),
            size_hint=(None, None),
            size=(400, 60),
            background_color=(0.5, 0.5, 0.5, 1)
        )
        center_layout.add_widget(self.spinner2)
        box_layout.add_widget(center_layout)
        right_panel.add_widget(box_layout)

        box_layout1 = CloseBoxLayout(orientation='vertical',size_hint_y=0.30)

        self.label = Label(text=f'Anomaly Detected: {self.anomaly_detected}', font_size=24, color=(0, 0.5, 0, 1))
        box_layout1.add_widget(self.label)
        fig, ax = plt.subplots(figsize=(4, 3))
        ax.set_facecolor('#f0f8ff')
        ax.set_title(f'Score')
        ax.set_xlabel('Time')
        ax.set_ylabel('Value')
        ax.set_ylim(0,100)
        self.canvas_score = FigureCanvasKivyAgg(fig)
        box_layout1.add_widget(self.canvas_score)
        right_panel.add_widget(box_layout1)

        self.box_layout2 = CloseBoxLayout(orientation='vertical')
    
        right_panel.add_widget(self.box_layout2)

        self.button1.bind(on_press=self.start_sim)
        self.button2.bind(on_press=self.stop_sim)
        #self.button3.bind(on_press=self.pause_sim)
        
        self.spinner1.bind(text=self.on_spinner_select_1)
        self.spinner2.bind(text=self.on_spinner_select_2)

        self.add_widget(self.left_panel)
        self.add_widget(right_panel)

    def create_networkx_graph(self,node_colors):
        G = nx.DiGraph()
        fig, ax = plt.subplots(figsize=(12, 8))
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

        G.add_nodes_from(nodes)
        G.add_edges_from(edges)
        ax.set_xlim(-12,14)
        ax.set_ylim(-12,8)
        ax.set_title(f'Causal Graph:', fontsize=12)
        nx.draw(G, pos,with_labels=True,node_size=1500, node_color=[node_colors[node] for node in G.nodes()], font_size=6, arrowsize=8,width=0.5)
        return fig

    def on_button_press(self, instance):
        # Toggle the display of the NetworkX graph
        if self.networkx_graph_display.figure.gca().has_data():
            self.networkx_graph_display.figure = plt.figure()
        else:
            self.networkx_graph_display.figure = self.create_networkx_graph(self.colors)
        self.networkx_graph_display.draw()
    
    def stop_sim(self, instance):
        self.sim.stopSimulation()
        print('Stop Simulation')
        self.clock_data.cancel()
        self.clock_plot.cancel()

        fig_score = self.canvas_score.figure
        ax_score = fig_score.axes[0]
        ax_score.cla()
        self.canvas_score.draw()

        for canvas in self.graphs:
            ax = canvas.figure.gca()  # Get the current axes
            ax.cla()  # Clear the current axes
            canvas.draw()

        self.t_data = pd.DataFrame()
        self.data_out = pd.DataFrame()
        
        #self.sim.setBoolParam(self.sim.boolparam_display_enabled, True)

    # def pause_sim(self, instance):
    #     self.sim.setBoolParam(self.sim.boolparam_display_enabled, True)
    #     self.sim.pauseSimulation()
    #     print('Pause Simulation')
    #     self.clock_data.cancel()
    #     self.clock_plot.cancel()
                
    def start_sim(self, instance):

         # NetworkX Graph Display
        self.networkx_graph_display = FigureCanvasKivyAgg(plt.figure())
        self.box_layout2.add_widget(self.networkx_graph_display)
        self.networkx_graph_display.figure = self.create_networkx_graph(self.colors)
        self.networkx_graph_display.draw()

        #self.sim.setStepping(True)
        self.sim.startSimulation()
        #self.sim.setBoolParam(self.sim.boolparam_display_enabled, False)
        print('Connection and Start Simulation')

        self.update_interval_data = 0.050  # Update interval in seconds
        self.clock_data = Clock.schedule_interval(self.update_data, self.update_interval_data)

        self.update_interval = 3  # Update interval in seconds
        self.clock_plot = Clock.schedule_interval(self.update_plots, self.update_interval)
        #self.sim.step()

    def detect_anomalies(self,data):
        window_size = 10
        threshold = 20
        earliest_anomaly_index = None
        data = data[['cam_1_X', 'cam_1_Y', 'cam_2_X', 'cam_2_Y', 'cam_3_X', 'cam_3_Y',
                    'rob_1_maxVel', 'rob_1_supply',
                    'rob_2_maxVel', 'rob_2_supply']]
        for column in data.columns:
            moving_avg = data[column].rolling(window=window_size).mean()
            diff = (data[column] - moving_avg).abs()
            anomaly_indices = diff[diff > threshold*moving_avg/100].index # 20% difference
            if not anomaly_indices.empty:
                first_anomaly_index = anomaly_indices[0]
                if earliest_anomaly_index is None or first_anomaly_index < earliest_anomaly_index:
                    earliest_anomaly_index = first_anomaly_index
        print(self.t_data['time'][earliest_anomaly_index])
        return earliest_anomaly_index

        
    def update_data(self,dt):
        
        all_data_row = pd.DataFrame()

        for obj in self.objects:
            obj_data = pd.DataFrame([self.sim.unpackTable(self.sim.readCustomDataBlock(obj,'customData'))])
            obj_data = self.data_process(obj_data)
            data = self.select_rename_columns(obj,obj_data)
            all_data_row = pd.concat([all_data_row,data],axis=1)
            if obj == self.camera_EoL:
                data_EoL = data

        EoL_nodes = ['EoL_1_X', 'EoL_1_Y',
                    'EoL_2_X', 'EoL_2_Y',
                    'EoL_3_X', 'EoL_3_Y',
                    'EoL_4_X', 'EoL_4_Y',
                    'EoL_5_X','EoL_5_Y',
                    'EoL_6_X', 'EoL_6_Y']
        
        for _, row in data_EoL.iterrows():
            non_zero_count = (row != 0.0).sum()
            total_count = len(EoL_nodes)
            score = (non_zero_count / total_count) * 100
            self.scores.append(score)
            score_dict = pd.DataFrame({'score':[score]})
            all_data_row = pd.concat([all_data_row,self.data_process(score_dict)],axis=1)

        #print(all_data_row)

        self.data_out = pd.concat([self.data_out, all_data_row],ignore_index=True)
        #print(self.data_out)
        self.t_data = pd.concat([self.t_data,pd.DataFrame({'time': [self.sim.getSimulationTime()]})], ignore_index=True)
        #print(self.sim.getSimulationTime())
        #self.sim.step()

    def run_RCA(self):

        self.clock_data.cancel()
        self.clock_plot.cancel()

        last_time = self.t_data['time'].iloc[-1]

        abnormal_index = self.t_data[self.t_data['time'] <= last_time-self.anomaly_gap].index[-1]


        warm_up_index =self.t_data[self.t_data['time'] <= 35].index[-1]

        print(self.detect_anomalies(self.data_out.loc[warm_up_index:]))


        #print(warm_up_index,abnormal_index) # at least 1 min before introduction of intervention

        results = []

        if warm_up_index < abnormal_index:
            # self.abnormal_data = self.data_out.loc[abnormal_index:]
            # self.normal_data = self.data_out.loc[warm_up_index:abnormal_index]

            self.abnormal_data = self.data_out.loc[self.intervention_index:]
            self.normal_data = self.data_out.loc[warm_up_index:self.intervention_index]

            main_dir = 'G:\My Drive\Master Thesis\Simulation\Test'
            folder_name = f'Test_1'
            folder_path = os.path.join(main_dir, folder_name)
            os.makedirs(folder_path, exist_ok=True)
            filename = 'abnormal.csv'
            self.abnormal_data.to_csv(os.path.join(folder_path, filename), index=False)

            filename = 'normal.csv'
            self.normal_data.to_csv(os.path.join(folder_path, filename), index=False)

            self.sim.setStepping(False)
            self.sim.pauseSimulation()

            results = self.run_HT(abnormal_df = self.abnormal_data,
                        normal_df = self.normal_data,
                        key_nodes = ['score'],
                        colors = self.colors)
            
        self.rca_activated = False

        print(results)

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
        elif text == 'Conveyor 1':
            self.graph_count = 1
            self.object = self.conveyor_1
        elif text == 'Conveyor 2':
            self.graph_count = 1
            self.object = self.conveyor_2
        elif text == 'Conveyor 3':
            self.graph_count = 1
            self.object = self.conveyor_3


        if self.graph_count > num_graphs:
            for i in range(self.graph_count-num_graphs):
                self.add_graph()
        elif self.graph_count < num_graphs:
            for i in range(num_graphs-self.graph_count):
                self.remove_graph()
        
        self.update_plots(3)

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
        if text == 'Gripper 1' or text == 'Gripper 2':
            self.anomaly_gap = 22.65
            self.intervention_index = self.t_data['time'].index[-1]
            self.sim.callScriptFunction(self.inter['Normal'],
                                        self.sim.getScript(self.sim.scripttype_customizationscript, self.inter_script))
            self.sim.callScriptFunction(self.inter[text],
                                        self.sim.getScript(self.sim.scripttype_customizationscript, self.inter_script))
        elif text == 'Normal':
            self.sim.callScriptFunction(self.inter[text],
                                        self.sim.getScript(self.sim.scripttype_customizationscript, self.inter_script))
            if self.sim.getSimulationState() != self.sim.simulation_stopped:
                self.normal_index = self.t_data['time'].index[-1]
    
    def select_rename_columns(self,obj,data:pd.DataFrame):
        if obj == self.camera_1:
            target_columns = ['sizeX', 'sizeY']
            target_rename = {'sizeX': 'cam_1_X', 'sizeY': 'cam_1_Y'}
        elif obj == self.camera_2:
            target_columns = ['sizeX', 'sizeY']
            target_rename = {'sizeX': 'cam_2_X', 'sizeY': 'cam_2_Y'}
        elif obj == self.camera_3:
            target_columns = ['sizeX', 'sizeY']
            target_rename = {'sizeX': 'cam_3_X', 'sizeY': 'cam_3_Y'}
        elif obj == self.conveyor_1:
            target_columns = ['speed']
            target_rename = {'speed': 'con_1'}
        elif obj == self.conveyor_2:
            target_columns = ['speed']
            target_rename = {'speed': 'con_2'}
        elif obj == self.conveyor_3:
            target_columns = ['speed']
            target_rename = {'speed': 'con_3'}
        elif obj == self.camera_EoL:
            target_columns = ['part1SizeX', 'part2SizeX', 'part3SizeX', 'part4SizeX',
                            'part1SizeY', 'part2SizeY', 'part3SizeY', 'part4SizeY',
                            'tray1SizeX', 'tray1SizeY', 'tray2SizeX', 'tray2SizeY']
            target_rename = {'part1SizeX': 'EoL_3_X', 'part2SizeX': 'EoL_4_X', 'part3SizeX': 'EoL_5_X', 'part4SizeX': 'EoL_6_X',
                            'part1SizeY': 'EoL_3_Y', 'part2SizeY': 'EoL_4_Y', 'part3SizeY': 'EoL_5_Y', 'part4SizeY': 'EoL_6_Y',
                            'tray1SizeX': 'EoL_1_X', 'tray1SizeY': 'EoL_1_Y',
                            'tray2SizeX': 'EoL_2_X', 'tray2SizeY': 'EoL_2_Y'}
        elif obj == self.rob_1:
            target_columns = ['jointVelo1', 'jointVelo2', 'jointVelo4', 'maxVel', 'gripperSupply', 'gripperVacuum', 'jointVelo3']
            target_rename = {'jointVelo1': 'rob_1_1', 'jointVelo2': 'rob_1_2', 'jointVelo3': 'rob_1_3', 'jointVelo4': 'rob_1_4',
                            'maxVel': 'rob_1_maxVel', 'gripperSupply': 'rob_1_supply', 'gripperVacuum': 'rob_1_vacuum'}
        elif obj == self.rob_2:
            target_columns = ['jointVelo1', 'jointVelo2', 'jointVelo4', 'maxVel', 'gripperSupply', 'gripperVacuum', 'jointVelo3']
            target_rename = {'jointVelo1': 'rob_2_1', 'jointVelo2': 'rob_2_2', 'jointVelo3': 'rob_2_3', 'jointVelo4': 'rob_2_4',
                            'maxVel': 'rob_2_maxVel', 'gripperSupply': 'rob_2_supply', 'gripperVacuum': 'rob_2_vacuum'}

        # Ensure all target columns are in the data, filling missing ones with 0
        for col in target_columns:
            if col not in data.columns:
                data[col] = 0

        data = data[target_columns]
        data = data.rename(columns=target_rename)
        data = data.fillna(0)  # Ensure no NaN values are left

        return data
        
    def select_columns(self,data):
        if self.object == self.camera_1:
            data = data[['cam_1_X','cam_1_Y']]
        elif self.object == self.camera_2:
            data = data[['cam_2_X','cam_2_Y']]
        elif self.object == self.camera_3:
            data = data[['cam_3_X','cam_3_Y']]
        elif self.object == self.conveyor_1:
            data = data[['con_1']]
        elif self.object == self.conveyor_2:
            data = data[['con_2']]
        elif self.object == self.conveyor_3:
            data = data[['con_3']]
        elif self.object == self.camera_EoL:
            data = data[['EoL_3_X','EoL_4_X','EoL_5_X','EoL_6_X',
                         'EoL_3_Y','EoL_4_Y','EoL_5_Y', 'EoL_6_Y',
                         'EoL_1_X','EoL_1_Y',
                         'EoL_2_X','EoL_2_Y']]
        elif self.object == self.rob_1:
            data = data[['rob_1_1','rob_1_2','rob_1_3','rob_1_4',
                         'rob_1_maxVel','rob_1_supply','rob_1_vacuum']]
        elif self.object == self.rob_2:
            data = data[['rob_2_1','rob_2_2','rob_2_3','rob_2_4',
                         'rob_2_maxVel','rob_2_supply','rob_2_vacuum']]
        return data
    
    def select_columns_EoL(self,data):
        data = data[['EoL_3_X','EoL_4_X','EoL_5_X','EoL_6_X',
                         'EoL_3_Y','EoL_4_Y','EoL_5_Y', 'EoL_6_Y',
                         'EoL_1_X','EoL_1_Y',
                         'EoL_2_X','EoL_2_Y']]
        data = data.fillna(0)
        return data

    def data_process(self,data : pd.DataFrame):
        return data.replace(np.nan, 0).replace({True: 1, False: 0})

    def update_plots(self,dt):
        
        if self.sim.getSimulationTime() > 0 and self.sim.getSimulationState() != self.sim.simulation_stopped:
            i = 0
            data = self.select_columns(self.data_out)

            fig_score = self.canvas_score.figure
            ax_score = fig_score.axes[0]

            anomaly = []

            if self.sim.getSimulationTime() > 100: 
                t_end = self.t_data['time'].iloc[-1]
                t_start = t_end-100
                ax_score.set_xlim(t_start,t_end)
                ax_score.set_ylim(0,100)

            if self.sim.getSimulationTime() > 33.75 and not self.anomaly_detected:
                if self.scores[-1] < 100:
                    t_end = self.t_data['time'].iloc[-1]
                    anomaly.append((self.t_data['time'].iloc[self.intervention_index], t_end)) #self.anomaly_gap
                    self.anomaly_detected = True
                    self.rca_activated = True
                    self.label.text = f'Anomaly Detected:{self.anomaly_detected}'

                for start, end  in anomaly:
                    ax_score.axvspan(start, end, color = 'orange', alpha=0.5)

                for canvas in self.graphs:
                    fig = canvas.figure
                    column = data.columns[i]
                    ax = fig.axes[0]
                    for start, end  in anomaly:
                        ax.axvspan(start, end, color = 'orange', alpha=0.5)


            ax_score.plot(self.t_data['time'], self.scores)
            self.canvas_score.draw()

            for canvas in self.graphs:
                fig = canvas.figure
                column = data.columns[i]
                ax = fig.axes[0]  # Assuming only one subplot per figure

                if self.sim.getSimulationTime() > 50: 
                    t_end = self.t_data['time'].iloc[-1]
                    t_start = t_end-50
                    ax.set_xlim(t_start,t_end)

                # Update plot with new data
                ax.plot(self.t_data['time'], data[column])

                # Adjust plot limits if needed (optional)
                ax.relim()
                ax.autoscale_view()

                ax.set_title(f'Data:{column}')
                ax.set_xlabel('Time')
                ax.set_ylabel('Value')
                # Redraw canvas to reflect updated plot
                canvas.draw()
                i +=1

            if self.rca_activated:
                self.run_RCA()
                        

    def run_HT(self,
            normal_df: pd.DataFrame,
            abnormal_df: pd.DataFrame,
            key_nodes: list,
            colors: dict):

        G = nx.DiGraph()
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
     
        G.add_nodes_from(nodes)
        G.add_edges_from(edges)  # Make sure `edges` is defined somewhere

        adj_matrix_extended_pd = nx.to_pandas_adjacency(G, nodes)
        
        interventions = {'gripper_1':'interGripper1',
                        'gripper_2':'interGripper2',
                        'max_Vel_1':'interVeloRob1',
                        'max_Vel_2':'interVeloRob2',
                        'camera_1':'interCamera1',
                        'camera_2':'interCamera2',
                        'camera_3':'interCamera3',
                        'conveyor_1':'interConveyor1',
                        'conveyor_2':'interConveyor2',
                        'conveyor_3':'interConveyor3',
                        'feeder_1':'interFeeder1',
                        'feeder_2':'interFeeder2',
                        'feeder_3':'interFeeder3',
                        'size_1':'interSize1',
                        'size_2':'interSize2',
                        'size_3':'interSize3'}

        model = HT(config=HTConfig(adj_matrix_extended_pd))
        model.train(normal_df)
        
        abnormal_nodes = []
        new_colors = colors.copy()
        results = pd.DataFrame()

        for node in key_nodes:
            if (abnormal_df[node] <100).any(): # Score instead of EoL
                abnormal_nodes.append(node)
                new_colors[node] = 'yellow'
                results[node] = model.find_root_causes(abnormal_df, node, True).to_list()

        rank1_root_cause = []
        rank2_root_cause = []
        rank3_root_cause = []

        for node in abnormal_nodes:
            rank1_root_cause.append(results[node][0]['root_cause'])
            rank2_root_cause.append(results[node][1]['root_cause'])
            rank3_root_cause.append(results[node][2]['root_cause'])

        for node in rank1_root_cause:
            new_colors[node] = 'red'

        for node in rank2_root_cause:
            new_colors[node] = 'crimson'

        for node in rank3_root_cause:
            new_colors[node] = 'lightcoral'

        self.networkx_graph_display.figure = self.create_networkx_graph(new_colors)
        self.networkx_graph_display.draw()

        return [[rank1_root_cause,rank2_root_cause,rank3_root_cause]]  

class MyApp(App):
    def build(self):
        self.title = 'Root Cause Analysis Demo - Pick and Place'
        return MainLayout()

if __name__ == '__main__':
    MyApp().run()
