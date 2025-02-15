# **CTree**  

CTree is a **CLI tool** designed to keep modular codebases manageable, especially in **AI-assisted development**. Instead of letting AI **dictate your workflow**, CTree helps **you** structure and extract code efficiently—giving you more **control and consistency.**  

Unlike typical AI automation tools, **CTree is human-first.** It’s not here to replace decision-making—it’s here to **enhance it.**  

I built CTree using **O1-Mini** to push beyond my current skill level, leveraging modular development to scale effectively.  

---

## **🚀 Why CTree?**  

Most AI tools are built to **automate everything**—but that approach has serious flaws:  

🚫 **AI doesn’t always know what you want.**  
🚫 **AI-generated outputs are often unpredictable.**  
🚫 **Without structure, AI solutions become inconsistent.**  

That’s where **CTree comes in.** It bridges the gap between **human intuition and AI execution** by giving you a structured way to:  

✅ **Organize complex ideas** before sending them to AI  
✅ **Generate structured outputs** that AI tools can follow  
✅ **Leverage AI’s power** without losing control  

Instead of **fighting against AI’s quirks**, CTree helps you **work with them**—ensuring AI stays an asset, not a liability.  

---

## **Example Workflow**  

1. **Request a change** – Describe what needs to be modified.  
2. **Modify the modular parts** – Implement the changes in the relevant components.  
3. **Use CTree to update project knowledge** – Run CTree on relevant directories like `components/base/` and `app/`.  
4. **Debug issues** – Paste VSCodium's problem output into a new chat and iterate.  
5. **Repeat the process** – Once the project is stable again, decide on the next improvement.  

When starting out, manually applying CTree to all necessary directories can take time. Over time, refining your workflow will make this process more efficient.  

---

## **⚡ Installation**  

Install CTree by running:  

```sh
sudo cp ctree.sh /usr/local/bin/ctree
sudo chmod +x /usr/local/bin/ctree
```

---

## **🔧 Setup**  

CTree uses two configuration files:  

### **1️⃣ `~/.ctreeconf` (File Extension Mappings)**  

Maps numeric flags to file extensions for selective extraction. Example:  

```ini
[flags]
1 = py
2 = tsx, jsx
3 = js, css
4 = json, ts
5 = json
6 = txt, md
7 = py, md, txt
8 = py
9 = tsx, ts, json, prisma
10 = java
```

### **2️⃣ `~/.ctreeignore` (Ignore Rules)**  

Defines which files and directories should be skipped. Example:  

```gitignore
node_modules/
__pycache__/
build/
*.log
```

To create these files, run:  

```sh
touch ~/.ctreeconf ~/.ctreeignore
```

Or copy an existing `.gitignore`:  

```sh
cp .gitignore ~/.ctreeignore
```

---

## **📌 Usage**  

### **🌳 Generate a Directory Tree**  

```sh
ctree -v .
```

### **📂 Extract Relevant Files**  

```sh
ctree -vv -a > output.ctree
```

### **🌟 Extracting Specific Code Sections**  

#### **FastAPI Project**  

Extract all routers:  

```sh
ctree -vv -o app/routers
```

Extract all service modules:  

```sh
ctree -vv -o app/services
```

#### **Monorepo Structure**  

Extract all packages:  

```sh
ctree -vv -o monorepo/packages
```

Extract all components:  

```sh
ctree -vv -o app/components
```

### **🎮 Custom Extraction**  

Extract specific file types using flags:  

```sh
ctree -vv -2 -o app/pages
```

Or specify custom extensions:  

```sh
ctree -vv -F yaml toml -o config app
```

Use a **custom ignore file**:  

```sh
ctree -vv -a -L /path/to/custom_ignore.txt
```

---

## **🧠 Who is CTree For?**  

CTree is built for:  

🔹 **AI developers** who need structured control over AI outputs  
🔹 **Engineers & researchers** working with complex, multi-layered projects  
🔹 **Anyone using AI tools like O1-Mini** who wants **more consistency & control**  

If you’ve ever been **frustrated by AI’s unpredictability**, CTree is the **missing piece** that helps you **take charge of AI interactions.**  

---

## **🛠 Final Thoughts**  

CTree **flips the usual AI workflow on its head.**  

Most AI tools are built to **replace human effort.** CTree is designed to **make human-AI collaboration stronger.**  

Instead of treating AI like an **autonomous worker**, CTree treats AI as a **tool that needs proper input to function effectively.**  

**This is one of the first true *human-first AI augmentation tools***—built to **empower, not replace.**  

🚀 **Take control of your AI interactions with CTree.**

