from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.button import Button
from kivy_garden.matplotlib.backend_kivyagg import FigureCanvasKivyAgg
import matplotlib.pyplot as plt

class GraphManager(BoxLayout):
    def __init__(self, **kwargs):
        super(GraphManager, self).__init__(**kwargs)
        self.orientation = 'vertical'
        self.graphs = []

        # Add initial graphs
        self.add_graph()

        # Button to add new graph
        self.add_graph_button = Button(text='Add Graph', size_hint=(1, None), height=50)
        self.add_graph_button.bind(on_press=self.add_graph)
        self.add_widget(self.add_graph_button)

        # Button to remove last graph
        self.remove_graph_button = Button(text='Remove Last Graph', size_hint=(1, None), height=50)
        self.remove_graph_button.bind(on_press=self.remove_graph)
        self.add_widget(self.remove_graph_button)

    def add_graph(self, *args):
        # Create a new figure and add it to the layout
        fig, ax = plt.subplots()
        ax.plot([1, 2, 3], [4, 5, 6])  # Example plot data
        canvas = FigureCanvasKivyAgg(fig)
        self.add_widget(canvas)
        self.graphs.append(canvas)

    def remove_graph(self, *args):
        # Remove the last added graph
        if self.graphs:
            graph_to_remove = self.graphs.pop()
            self.remove_widget(graph_to_remove)

class GraphApp(App):
    def build(self):
        return GraphManager()

if __name__ == '__main__':
    GraphApp().run()
