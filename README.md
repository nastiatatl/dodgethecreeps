# Dodge the Creeps! Expanded

This project started as a follow-up to the official Godot "Your First 2D Game" tutorial, which you can find [here](https://docs.godotengine.org/en/stable/getting_started/first_2d_game/index.html). The goal was to expand upon the tutorial to deepen my understanding of game development and Godot Engine, adding more game features. This repository was created for educational purposes only and is not intended for commercial use or monetization.

## New Features

All features listed below were not part of the original tutorial linked above:

1. **Coin spawning**: player can collect coins that spawn randomly every 3 seconds. Special **big coins** have a 10% chance to spawn instead of normal coins. Big coins are worth 5 regular coins but disappear after 5 seconds.
2. **Coin counter**: keeps count of how many coins were collected by player.
3. **Special items**: spawn every five seconds, see below for specific items:
   1. **Heart**: gives the player a spare life. Once the player hits a mob, the lives counter goes down, and the player becomes invincible for 2 secons, losing the ability to collect coins and items.

## License
This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License. You are free to use, modify, and share the project for non-commercial purposes only. Commercial use is prohibited.