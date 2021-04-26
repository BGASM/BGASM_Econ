### BGASM Econ
BGASM Econ runs a lua process to harvest all tradedata from player known stations. This is sent to a python
script using SirNuke's X4 Python Pipe Server. The data is sorted and passed to a pandas pivottable script
that generates an html file in the mod directory and opens your browser to the page.

As the script runs it will continue to harvest every minute. The html file only replaces values that 
have changed.
![alt text](./img/Demo.png "Cowboy")
![alt text](./img/Demo2.png "Cowboy")

### Installation
**To use this mod you need to have SirNukes X4 Python Pipe Server running.**  
- Download it at https://github.com/bvbohnen/x4-projects/releases.
- Clone this git and use pip install requirements.txt or you can use Poetry.
- Download the zip file from release - you will still need to install two dependencies!
- BGASM_Econ folder needs to be placed in your /extensions directory in X4 installation folder.

Requrements: Python ^3.6, Pandas, IPython, pivottablesjs and their associated dependencies.
- You can use pip install requirements.txt


### Use
Install the dependencies, run SirNukes Python Pipe Server, and make sure you have a web browser installed.


### Future Development
I started working on a lightweight sqlite3 DB that will store price changes over time.

### Contribute
If you want to take a swing at this code, please by all means. Fork a branch and send me a PR.
If you can help me figure out a way to make this more distributeable without grossly overwriting SirNukes
Server code, please let me know. That was how I initially debugged the code was with his source build.