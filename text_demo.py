from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.anchorlayout import AnchorLayout
from kivy.uix.button import Button


class AnchorBoxLayoutApp(App):
    def build(self):
        # Create a vertical BoxLayout as the root widget
        self.root = BoxLayout(orientation='vertical')

        # Create an AnchorLayout for the centered content
        anchor_layout = AnchorLayout(anchor_x='center', anchor_y='center')

        # Add a Button to the AnchorLayout
        button = Button(text='Centered Button', size_hint=(None, None), size=(150, 50))
        anchor_layout.add_widget(button)

        # Add the AnchorLayout to the BoxLayout
        self.root.add_widget(anchor_layout)

        return self.root


if __name__ == '__main__':
    AnchorBoxLayoutApp().run()
