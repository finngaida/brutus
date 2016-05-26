# Brutus
Caesar / Viginère encoding &amp; decoding tool

## What?
This is a simple macOS app that takes a `.txt` file as input and en-/decrypts it into an output file `Ver(Ent-)schlüsselt.txt` using the given key.
It's also capable of 'cracking' single-char-key-encrypted (Caesar-encrypted) files by analyzing the relative frequencies of every character and then comparing those frequencies to the normal frequencies in a sample german text. This feature only works on german Text files and spits out 4-5 possible solutions, often times the second or third file is the correct one.

## Why?
I wrote this app as a part of my Abitur (A-Levels). The topic is Cryptology and this app was used to demonstrate the weaknesses of symmetrically encrypted texts using the Caesar-chiffre.

## How?
The magic happens in [Crypt.swift](Brutus/Crypt.swift) which is mostly documented to in-line.
Saving, reading and displaying is done in the view controller classes.

## 2Do
- Write tests
- Reduce trash output on cracking
- Implement Viginère cracking by using [this](http://www.swisseduc.ch/informatik/daten/kryptologie_geschichte/docs/vigenere_knacken_loesung.pdf)

## License
MIT pretty much, the logo was inspired by [Dribbble](https://dribbble.com/shots/2517035-Caesar), use it as you like and let me know if you do something cool.