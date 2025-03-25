# ChatMDX
**💬 AI Chat Frontend made in flutter for all platforms**
### **A sleek, customizable, and multi-API AI chat app powered by Flutter!**
![Windows Chat UI Banner](https://via.placeholder.com/1000x300?text=Your+Project+Banner+Here)

🎨 **Beautiful UI** • 🔌 **Custom API Support** • 📝 **MDX-Powered Responses** • ⚡ **Flutter-Powered & Cross-Platform**

---

## **🚀 Features at a Glance**
✅ **Windows-First, Cross-Platform Ready** – Works on **Windows now**, expanding to macOS, Linux, Web & Mobile.

✅ **Multi-API Support** – OpenAI, Claude, Mistral, Local LLMs, and more.

✅ **MDX-Powered Responses** – AI can return rich **Markdown + JSX**.

✅ **Tabbed Conversations** – Manage multiple chat sessions like a browser.

✅ **Customizable Themes** – Light, Dark, and custom themes.

✅ **Plugin System** – Extend functionality with custom scripts & APIs.

✅ **File Upload & AI Analysis** – PDFs, CSVs, and DOCX support.

✅ **Voice Input & TTS Output** – Talk to your AI assistant.

✅ **Memory & AI Personas** – AI remembers context & adapts its style.

---

## **📸 Screenshots**
| Chat Interface | Plugin System | Custom Themes |
|---------------|--------------|---------------|
| ![Chat](https://via.placeholder.com/300) | ![Plugins](https://via.placeholder.com/300) | ![Themes](https://via.placeholder.com/300) |

---

## **🛠️ Installation & Setup**
### **🔹 Prerequisites**
- **Windows 10/11** (macOS/Linux support coming soon 🚀)
- **Flutter SDK** (latest stable)
- **API Keys** (OpenAI, Claude, or custom LLMs)

### **🔹 Install & Run**

#### **📦 Clone & Setup**
Make sure to create a .env file and set your CABLY_API_KEY
```bash
git clone https://github.com/CodeDreamer06/ChatMDX
cd ChatMDX
flutter pub get
```

#### **▶️ Run on Windows**
```bash
flutter run -d windows
```

#### **▶️ Run on Other Platforms (Upcoming)**
```bash
flutter run -d macos  # macOS (Coming Soon)
flutter run -d linux  # Linux (Coming Soon)
flutter run -d web    # Web (Planned)
flutter run -d android  # Android (Future)
flutter run -d ios      # iOS (Future)
```

### **🔹 Configuration**
1. **Set API Keys** in `.env` or via UI settings.
2. **Choose AI Models** from the settings panel.
3. **Customize Themes & Plugins** as needed.

---

## **🔌 Plugin System**
Easily extend the app by adding **custom plugins**!
```dart
class MyPlugin {
  String process(String input) {
    return "Processed: $input";
  }
}
```
📍 **Add your plugin** via the UI or `plugins/` folder.

## **🎯 Roadmap & Upcoming Features**
✅ **Windows-first release**

✅ **Multi-API support**

✅ **MDX-based responses**

✅ **Custom AI Personas**

🔄 **macOS & Linux support** (Coming Soon!)

⚡ **AI-Powered Workflows & Automation** (Planned)

📱 **Mobile (Android & iOS) support** (Future)

---

## **🤝 Contributing**
Want to make this even better? **Fork, clone, and PR!**
```bash
git checkout -b feature-branch
git commit -m "Added cool feature"
git push origin feature-branch
```
📢 **Join the discussion!** Open issues & share ideas.

---

## **📜 License**
📝 MIT License – Use, modify, and contribute freely!

---

## **🌟 Star This Repo!**
If you like this project, **give it a star ⭐** and share it! 🚀

🔗 **[GitHub Repo](https://github.com/your-username/your-repo)** | 💬 **[Join the Community](https://discord.gg/your-invite)**

---