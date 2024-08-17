### Overview
This aseprite script non-destructively creates an outline for multiple layers as if they merged before being outlined. (It does NOT actually merge the layers).
The outline is created on a new layer named "Outline"

Note: aseprite's default outline function will create an outline for each layer individually, this creates an outline for all the layers as a whole

## Features
* Generates a single outline for multiple layers without having to merge them
* Control over which cels, frames, and layers are outlined
* Customizable outline thickness and color
* Non-destructive: outline is added to a new, easily removable layer

## How to use
### 1. [Install](https://community.aseprite.org/t/aseprite-scripts-collection/3599)
Just download **Outline Merged.lua** and drop it into the scripts folder <br>
![image](https://github.com/Arktii/aseprite-outline-merged/assets/72131971/e0be082a-71df-4196-90ba-ac07684303d7)

### 2. Run the script (**Outline Merged.lua**)
![image](https://github.com/Arktii/aseprite-outline-merged/assets/72131971/cbf4b1f5-d6c2-45d5-af1a-fff42acca9cf)

### 3. Select layers or cells
![image](https://github.com/Arktii/aseprite-outline-merged/assets/72131971/7eb5fa89-ee23-4682-b32d-c4bba11b292e) <br>
OR <br>
![image](https://github.com/Arktii/aseprite-outline-merged/assets/72131971/b9d8bb04-644b-47b0-ae5a-0f6db272cf9c)

### 4. Click Outline 
![image](https://github.com/user-attachments/assets/805de308-e6d8-4539-8345-63a5491a2417)

### Result:
![image](https://github.com/Arktii/aseprite-outline-merged/assets/72131971/9e751649-edc9-4b18-86ba-64a2e91216cc) <br>
Observe there is no change to the original layers, making it easy to undo <br>

### Comes with options to change outline style
![image](https://github.com/user-attachments/assets/58be0477-3f54-41f9-84cf-ecc927a5c813)
![image](https://github.com/Arktii/aseprite-outline-merged/assets/72131971/1761f53d-277c-49e5-ae34-f1eab6861d66)

### Example where cels are selected instead of entire layers
Notice that outlines are only created in the frames with selected cells <br>
![image](https://github.com/Arktii/aseprite-outline-merged/assets/72131971/f4bc3267-f6c7-4789-8592-55750a3e5069)
