import tkinter as tk
import requests
import time

# Constants
WIDTH, HEIGHT = 64, 32  # Set to match your Lua display buffer

def fetch_display_buffer():
    try:
        response = requests.get("http://127.0.0.1:5000/get_display")
        if response.status_code == 200:
            return response.json().get("displayBuffer")
    except requests.RequestException as e:
        print(f"Error fetching display buffer: {e}")
    return None

def update_canvas(display_buffer):
    canvas.delete("all")
    if display_buffer:
        for i, pixel in enumerate(display_buffer):
            x = (i % WIDTH) * 10
            y = (i // WIDTH) * 10
            color = "white" if pixel == 1 else "black"
            canvas.create_rectangle(x, y, x + 10, y + 10, fill=color, outline="")

def refresh_display():
    display_buffer = fetch_display_buffer()
    if display_buffer:
        update_canvas(display_buffer)
    root.after(500, refresh_display)  # Refresh every 50 ms

root = tk.Tk()
root.title("Display Buffer Viewer")
canvas = tk.Canvas(root, width=WIDTH*10, height=HEIGHT*10)
canvas.pack()

root.after(50, refresh_display)
root.mainloop()
