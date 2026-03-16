# Braw Project Template

This repository is a **GitHub Template Repository** for creating new C++ projects using:

- Cross‑platform Clang toolchain
- CMakePresets for Windows, Linux, macOS
- VS Code development environment
- Auto‑discovered source/include layout
- Example application
- Install rules for packaging
- Automatic versioning
- Project generator script

Click **Use this template → Create new repository** to start a new project.

Before opening the project please

Install msys2 then
 - pacman -Syu
 - pacman -S \
  mingw-w64-ucrt-x86_64-clang \
  mingw-w64-ucrt-x86_64-gdb \
  mingw-w64-ucrt-x86_64-cmake \
  mingw-w64-ucrt-x86_64-ninja \
  mingw-w64-ucrt-x86_64-toolchain
 - C:\msys64\ucrt64\bin add to path
