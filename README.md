<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/nicolodiamante/prune/assets/48920263/5726f14d-bd72-4ab9-a44a-874e09f87b78" draggable="false" ondragstart="return false;" alt="prune" title="prune" />
    <img src="https://github.com/nicolodiamante/prune/assets/48920263/1020d578-463a-4283-999f-1bbbdb15bebc" draggable="false" ondragstart="return false; "alt="prune" title="prune" />
  </picture>
</p>

The [Launchpad][apple-launchpad] on a Mac serves as a quick access hub to all installed applications. With a simple gesture or a click, it displays an easy-to-navigate grid of app icons, providing a user-friendly way to launch applications without digging through the Applications folder. However, over time, as more applications get installed, the Launchpad can become cluttered with icons, including those of seldom-used or obsolete apps. This accumulation of icons can hinder easy access to frequently used apps, transforming a feature initially intended for convenience into a source of potential annoyance.

Prune is a script designed to automate the removal of specified apps from the Launchpad, helping maintain a clean, tidy, and efficient app launch interface. By specifying which apps you want to keep or remove through a simple configuration, Prune takes care of the rest. It delves into the system, meticulously removes the selected apps from the Launchpad, and leaves it in a clean and organised state.

<br><br>

<p align="center">
  <picture>
    <img src="https://github.com/nicolodiamante/prune/assets/48920263/ebb5be63-7db8-47be-bb5f-acc3230e4bf7" draggable="false" ondragstart="return false; "alt="Launchpad" title="Launchpad" width="700px" />
  </picture>
</p>
<br>

## Getting Started

### Installation

The installation process of Prune is streamlined for simplicity. You can automatically download and install Prune via `curl` by executing the following command in your terminal:

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/nicolodiamante/prune/HEAD/bootstrap.sh)"
```

If you prefer a more manual approach, you can clone the repository to your local machine using `git` with the command:

```shell
git clone https://github.com/nicolodiamante/prune.git
```

After cloning the repository, navigate to its directory in the terminal, then move to the `utils` subdirectory and run the installation script `install.sh` as follows:

```shell
source install.sh
```

When you run the installation script, it performs two main actions to set up Prune on your system. Firstly, it copies the agent files into the `~/Library/LaunchAgents` directory. This step ensures that the necessary agent files are placed in the correct location, allowing the system to recognise and execute them as needed. Secondly, the script adds an alias to your shell configuration file `.zshrc`, making it easier for you to invoke Prune from the terminal.

```shell
# Launch the Prune script.
alias prune='$HOME/prune/scripts/prune.zsh'
```

These steps will ensure Prune is properly set up on your system, ready to assist you in managing your Launchpad efficiently and effortlessly.
<br><br>

## How It Works

Prune operates through a trio of components: a configuration file, a script, and a plist file for automation. The heart of Prune lies in its straightforward configuration file named `apps`, where you specify which apps to keep or remove from the Launchpad. It's crucial to write down the app names exactly as they appear on your Mac, including spaces, capitalisation, etc., to ensure accurate matching. Each app name should be on a new line and enclosed in single quotes, like so:

<p align="center">
  <picture>
    <img src="https://github.com/nicolodiamante/prune/assets/48920263/fbaaf272-5d08-42ec-8fab-49803796cf9f" draggable="false" ondragstart="return false; "alt="Prune Apps List" title="Prune Apps List" width="750px" />
  </picture>
</p>
<br>

By managing the list of app names in the `apps` file, you are essentially guiding Prune on which apps to retain or remove from the Launchpad. The core script, `.pruneops.zsh`, reads this file, translates your preferences into actions, and executes the necessary commands to tidy up your Launchpad.

For continuous tidiness, Prune leverages a plist file, allowing it to run automatically each time your Mac starts. This plist file, loaded via `launchctl`, points to `.pruneops.zsh` ensuring that every time your Mac boots up, Prune checks the `apps` file and cleans up your Launchpad accordingly.

Besides the automatic cleanup, you can also invoke Prune manually whenever needed. By typing `prune` in the terminal, you initiate the script. Upon entering your password, Prune swings into action, clearing away the unwanted apps from the Launchpad as specified in the `apps` file.

<br><br>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/nicolodiamante/prune/assets/48920263/ce8fee13-f07f-4ade-987c-20dfe07d6a62" draggable="false" ondragstart="return false;" alt="Prune Terminal" title="Prune Terminal" />
    <img src="https://github.com/nicolodiamante/prune/assets/48920263/e75ead0a-cfae-46ce-af7e-0b3143f9eb9b" draggable="false" ondragstart="return false; "alt="Prune Terminal" title="Prune Terminal" width="750px" />
  </picture>
</p>
<br><br>

This blend of automated and manual operation, fueled by a simple configuration, makes Prune a powerful tool for maintaining a clutter-free, organised Launchpad, whether you're at the helm or letting it run on autopilot.<br><br>

### How to Reset Launchpad Layout

In case you wish to restore the Launchpad to its original state, erasing the customisations made by Prune, a simple command is built into the script for this purpose. By invoking `prune --default` or `prune -d` in the terminal, the Launchpad will revert to its default layout, including all apps and their original organisation. This action utilises a native macOS command to reset the Launchpad, ensuring a safe and straightforward return to the default setup. It's a quick way to undo Prune's changes, should you ever want to start afresh with your Launchpad organisation<br><br>

### Loading and Unloading Prune Agent

Prune's functionality is driven by a background agent that automates the cleaning of your Launchpad based on the preferences you've set. There might be instances where you'd want to stop the agent temporarily or start it after it has been stopped. Prune provides simple commands for these actions:

To load the Prune agent:

```shell
prune -l
```

To unload the Prune agent:

```shell
prune -u
```

These commands allow you to control the Prune agent's activity on your system.

### Verifying Prune Agent Status

After loading or unloading the Prune agent, it's good practice to check its status to ensure it's operating as intended:

```shell
prune -c
```

A successful check should return the following output, indicating that the Prune agent is active and loaded:

<br><br>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/nicolodiamante/prune/assets/48920263/11cf711d-5c80-4f27-9c40-ca4c6e9beede" draggable="false" ondragstart="return false;" alt="Prune checking Agent" title="Prune checking Agent" />
    <img src="https://github.com/nicolodiamante/prune/assets/48920263/34c758f0-825e-40d6-8062-df9bf46ca742" draggable="false" ondragstart="return false; "alt="Prune checking Agent" title="Prune checking Agent" width="750px" />
  </picture>
</p>
<br><br>

If the Prune agent is not loaded, there will be no output.

This verification step assures that Prune is set up correctly and ready to keep your Launchpad organised. It's a handy tool for troubleshooting and confirming the agent's operational status.<br><br>

### Removing a Specific App from the Launchpad

Prune now offers the ability to remove a specific app from your Launchpad. This feature is useful when you want to declutter your Launchpad by removing individual apps without affecting others.

To remove a specific app:

```shell
prune -r [AppName]
```

Replace `[AppName]` with the exact name of the app you wish to remove from the Launchpad.

For example, to remove an app named `"QuickTime Player"`, you would use:

```shell
prune -r "QuickTime Player"
```

This command will instruct Prune to specifically remove the `"QuickTime Player"` from your Launchpad.

**Note:** Be sure to use the exact name of the app as it appears in your Launchpad. The removal is case-sensitive and requires the full app name.<br><br>

### Accessing Help

Prune comes with a built-in help option to provide quick access to its usage instructions right from the terminal. Whether you're unsure about how to reset the Launchpad layout or need a reminder about how to launch Prune, the help option is there to assist you. To access this, simply type `prune --help` or `prune -h` in the terminal. This will display a summary of available options and how to use them.<br><br>

## Notes

### Restoring App Icons to Launchpad

If you wish to re-add an application icon to the Launchpad after it has been removed by Prune, you'll need to manually add it back. This can be done easily by finding the application in your Applications folder, and then dragging and dropping the application icon onto the Launchpad icon in your Dock. Remember, Prune is here to help keep your Launchpad tidy by automating the removal of specified apps, but re-adding apps to the Launchpad is a manual process.

<br><br>

<p align="center">
  <picture>
    <img src="https://github.com/nicolodiamante/prune/assets/48920263/5643b393-15a8-4f1c-aa3c-61162a6237be" draggable="false" ondragstart="return false; "alt="Add apps to Launchpad" title="Add apps to Launchpad" width="700px" />
  </picture>
</p>

<br>

### Resources

- [Launchpad User Guide][apple-guide]

### Contribution

Any suggestions or feedback you may have for improvement are welcome. If you encounter any issues or bugs, please report them to the [issues page][issues].
<br><br>

<p align="center">
  <picture>
    <img src="https://github.com/nicolodiamante/prune/assets/48920263/71f05fea-d2e9-45b0-9af4-e8cfbb5bb9dd" draggable="false" ondragstart="return false;" /></>
  </picture>
</p>

<p align="center">
  <a href="https://nicolodiamante.com" target="_blank">
    <img src="https://github.com/nicolodiamante/prune/assets/48920263/5deb9f27-b6ed-474b-8095-bc221cee1ea0" draggable="false" ondragstart="return false;" alt="Nicol&#242; Diamante Portfolio" title="Nicol&#242; Diamante" width="17px" />
  </a>
</p>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/nicolodiamante/prune/assets/48920263/4f83278b-5eee-466e-8395-8193cee8397b" draggable="false" ondragstart="return false;" alt="MIT License" title="MIT License" />
    <img src="https://github.com/nicolodiamante/prune/assets/48920263/372ab778-d7dd-46ef-a91d-a9a619bc1145" draggable="false" ondragstart="return false; "alt="MIT License" title="MIT License" width="95px" />
  </picture>
</p>

<!-- Link labels: -->

[apple-launchpad]: https://support.apple.com/en-gb/guide/mac-help/mh35840/mac
[apple-guide]: https://support.apple.com/en-gb/guide/mac-help/mh35840/mac
[issues]: https://github.com/nicolodiamante/prune/issues
