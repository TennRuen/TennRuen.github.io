@echo off
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& 'd:\Antigravity\portfolio\compress_images.ps1'"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& 'd:\Antigravity\portfolio\update_gallery.ps1'"
pause
