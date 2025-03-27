# FireClip

A simple, open-source clipboard manager designed to help you keep track of your clipboard history.

## Features
- Capture clipboard text automatically
- Search through clipboard history
- Copy and delete individual clipboard entries
- Completely open-source and privacy-focused

## Download

### Windows
- [Take me to the Downloads](https://github.com/firestuffteam/FireClip/releases/latest)

### Linux
#### **Pre-built Debian Package (May Not Work)**
You can try installing FireClip via APT, but Linux builds may have issues due to missing dependencies.

```bash
echo "deb [trusted=yes] https://firestuffteam.github.io/FireClip-APT stable main" | sudo tee /etc/apt/sources.list.d/fireclip.list
sudo apt update
sudo apt install fireclip
```

If you encounter missing libraries (e.g., `libscreen_retriever_plugin.so`), you may need to build FireClip manually.

## **Building FireClip on Linux**
If the pre-built Debian package does not work, you can build FireClip manually:

### **Dependencies**
Ensure you have the required dependencies installed:
```bash
sudo apt update
sudo apt install flutter cmake ninja-build pkg-config libgtk-3-dev
```

### **Clone & Build**
```bash
git clone https://github.com/firestuffteam/FireClip.git
cd FireClip
flutter build linux
```

The built binary will be located in:
```
build/linux/x64/release/bundle/
```
Run it with:
```bash
./build/linux/x64/release/bundle/fireclip
```

## **Creating a .desktop Entry**
To integrate FireClip with your system menu, create a `.desktop` file:

1. Create the file:
```bash
nano ~/.local/share/applications/fireclip.desktop
```

2. Add the following content:
```ini
[Desktop Entry]
Name=FireClip
Exec=/path/to/fireclip
Icon=/path/to/fireclip-icon.png
Terminal=false
Type=Application
Categories=Utility;
```
Replace `/path/to/fireclip` with the actual path to your built executable.

3. Make it executable:
```bash
chmod +x ~/.local/share/applications/fireclip.desktop
```

Now FireClip should appear in your application launcher.

---

## **Contributing**
Pull requests are welcome! Feel free to fork the repo and submit changes.

## **License**
FireClip is open-source and licensed under the MIT License.

---

[Download For Windows Now](https://github.com/firestuffteam/FireClip/releases/latest)

