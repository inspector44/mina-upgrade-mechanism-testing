# Mina UMT: Installation and Setup Guide

Welcome to the Mina Upgrade Mechanism Testing repository! This documentation assists you through the necessary installations and configurations to participate in Mina's UMT.

## 🚀 Introduction

This repository provides a user-friendly and interactive script to guide participants through setting up their environment for engaging with Mina UMT tests. Tailored for ease and simplicity, this script will prompt you through each step, ensuring a smooth and efficient setup process. Please adhere to the guidelines for an efficient and trouble-free setup and testing experience.

## 📋 Prerequisites

Ensure that:
- You have root user access for managing installations and configurations.
- Note that there are two different sh files, Pre-Upgrade and Post-Upgrade. 

## 🛠 Installation & Configuration

Follow these step-by-step instructions to set up your environment for Mina UMT.

### 1️⃣ Step 1: Switch to Root User

Ensure that you have root user access to handle the necessary installations and configurations seamlessly:

```bash
sudo su - root
```

### 2️⃣ Step 2: Creation and Configuration of init.sh
If you are going to run block producer for Pre-Upgrade you should use the file pre-upgrade-init.sh. If you will run block producer for Post-Upgrade you should use post-upgrade-init.sh.

Create a new shell script named init.sh and insert the required scripts:

```bash
nano init.sh
```

A text editor will open upon execution. Copy and paste the script shared in this repository, save, and exit the editor.

### 3️⃣ Step 3: Modify Script Permissions
Assign execution permissions to init.sh with:

```bash
chmod +x init.sh
```
### 4️⃣ Step 4: Execute the Configuration Script
Run the init.sh script:

```bash
./init.sh
```

During execution, the script will prompt you to input information sequentially. Find and enter the necessary values from the provided zip file.

### 4️⃣ Step 4: Check the status
Wait for 5 minutes. Then check the daemon by using below command.
```bash
mina client status
```

