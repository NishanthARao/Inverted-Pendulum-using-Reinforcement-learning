# Inverted-Pendulum-using-Reinforcement-learning
Anderson - Barto - Sutton's implementation (1983) on MATLAB-SIMULINK 

This is an implementation of the paper - "Neuronlike adaptive elements that can solve difficult learning control problems" by Andrew G Barto, Richard S Sutton and Charles W Anderson. You can find the paper here:

http://www.derongliu.org/adp/adp-cdrom/Barto1983.pdf

The entire project is based on this paper. Some references for building the MATLAB code has been adapted from here:
https://github.com/david78k/pendulum/blob/master/c/anderson/pole.c

Download all the files into the same folder say "XYZ".

Extract the files present in the "NecessaryFiles.zip" to "XYZ". This is important as all the cart-pole animation is present here.

For your convenience, previous versions of simulink file, and 2017 versions are present.

To view the animation, click on the "VR sink" system (The one that has pink sphere and stuff like that".
The simulation time can be reduced by placing a "Real time pacer" block to view real time simulation; However, i havent included them in this file due to some system specific errors. You can download it from mathworks.

The number of episodes will appear on a "display" block. Due to the animation, the processing maay be slowed down, and the number of episodes will increase slowly.

Thus, a MATLAB file has also been included, which has no animation, but gives the number of episodes before which the pole will balance. The threshold is set for 100 trials, in which the pole may or may not balance, due to the noise that has been intentionally added.

Make sure to play around with the hyperparameters! (constant blocks in the simulink file/ CAPITAL LETTER WORDS in matlab file)
