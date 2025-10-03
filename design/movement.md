Timing windows

	- Timing windows shall always be larger than 1 frame
	
	- With frame perfect timings, RNG plays a very large role in consistency
		* This is especially egregious for pressing the same button on the same frame, where the timing window varies from <1ms to 16.666ms and it's super easy to get caught between frames by pressing one input on the last milisecond of a frame, then then next input on the first second of the next
		
		* This is made even worse with low polling rate keyboards, where the chance of getting caught between frames is much higher as in addition to missing the frame window you might also end up only   having 2 polling updates per frame, then ending up on the third one even though you pressed both inputs within a single frame
	
	- It was extremely hard to write this section without saying "frame bus"


Slideboosts

	- What are they?
		* A small impulse of horizontal speed in the direction of a slide
		
	- What triggers them?
		* Slideboosts are triggered when you slide above a speed threshold
		* (This threshhold can be exceeded by walking in a straight line)
		
	- When can I slideboost?
		* Unlike Slideboosts in TF2 (which operate on a cooldown), these operate as more of a "one time use"
		
		* When you slideboost, you temporarily lose the ability to slideboost until you go below the speed threshold again
