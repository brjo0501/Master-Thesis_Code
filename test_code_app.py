import tkinter as tk
from tkinter import filedialog
from tkinter import ttk
import networkx as nx
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

class CausalGraphApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Interactive Causal Graph")
        
        # Initialize the graph
        self.graph = nx.DiGraph()
        self.initialize_graph()
        
        # Set up the GUI
        self.setup_gui()
        
    def initialize_graph(self):
        # Create a simple initial graph
        self.graph.add_node(1, label='Node 1')
        self.graph.add_node(2, label='Node 2')
        self.graph.add_node(3, label='Node 3')
        self.graph.add_edge(1, 2, weight=1.5)
        self.graph.add_edge(2, 3, weight=2.0)
        self.graph.add_edge(3, 1, weight=2.5)
    
    def setup_gui(self):
        # Left frame for the graph
        self.left_frame = tk.Frame(self.root)
        self.left_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Right frame for controls
        self.right_frame = tk.Frame(self.root)
        self.right_frame.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Add a Canvas to draw the graph
        self.fig, self.ax = plt.subplots()
        self.canvas = FigureCanvasTkAgg(self.fig, master=self.left_frame)
        self.canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)
        self.draw_graph()
        
        # Add mode selection
        self.mode_label = tk.Label(self.right_frame, text="Select Mode:")
        self.mode_label.pack(pady=5)
        
        self.mode_var = tk.StringVar()
        self.mode_combobox = ttk.Combobox(self.right_frame, textvariable=self.mode_var)
        self.mode_combobox['values'] = ('Add Node', 'Remove Node', 'Add Edge', 'Remove Edge')
        self.mode_combobox.pack(pady=5)
        
        # Add file selection
        self.file_label = tk.Label(self.right_frame, text="Select File:")
        self.file_label.pack(pady=5)
        
        self.file_var = tk.StringVar()
        self.file_button = tk.Button(self.right_frame, text="Browse", command=self.browse_file)
        self.file_button.pack(pady=5)
        
        self.file_entry = tk.Entry(self.right_frame, textvariable=self.file_var)
        self.file_entry.pack(pady=5)
        
        # Add compute button
        self.compute_button = tk.Button(self.right_frame, text="Compute", command=self.compute)
        self.compute_button.pack(pady=20)
    
    def draw_graph(self):
        self.ax.clear()
        pos = nx.spring_layout(self.graph)
        nx.draw(self.graph, pos, ax=self.ax, with_labels=True, node_size=500, node_color='skyblue', font_size=10, font_weight='bold')
        self.canvas.draw()
    
    def browse_file(self):
        filename = filedialog.askopenfilename()
        self.file_var.set(filename)
    
    def compute(self):
        mode = self.mode_var.get()
        filename = self.file_var.get()
        
        if not mode or not filename:
            return
        
        # Implement logic to modify the graph based on mode and file
        if mode == 'Add Node':
            self.graph.add_node(len(self.graph.nodes) + 1, label=f'Node {len(self.graph.nodes) + 1}')
        elif mode == 'Remove Node':
            if self.graph.nodes:
                self.graph.remove_node(len(self.graph.nodes))
        elif mode == 'Add Edge':
            nodes = list(self.graph.nodes)
            if len(nodes) > 1:
                self.graph.add_edge(nodes[-2], nodes[-1], weight=1.0)
        elif mode == 'Remove Edge':
            edges = list(self.graph.edges)
            if edges:
                self.graph.remove_edge(*edges[-1])
        
        # Update the graph drawing
        self.draw_graph()

if __name__ == "__main__":
    root = tk.Tk()
    app = CausalGraphApp(root)
    root.mainloop()
