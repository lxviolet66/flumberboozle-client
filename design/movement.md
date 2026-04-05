# Timing windows
	- Timing windows should always be larger than 1 frame

	- With frame perfect timings, RNG plays a very large role in consistency
		* This is especially egregious for pressing the same button on the same frame, where the timing window varies from 0ms to 16.666ms and it's super easy to get caught between frames by pressing one input on the last milisecond of a frame, then then next input on the first second of the next

		* This is made even worse with low polling rate keyboards, where the chance of getting caught between frames is much higher as in addition to missing the frame window you might also end up only having 2 polling updates per frame, then ending up on the third one even though you pressed both inputs within a single frame

	- It was extremely hard to write this section without saying "frame bus"

	- A lot of the shit here is wrong wtf was  i cooking but point jkind of still stnads?


# Slideboosts
	- A small impulse of horizontal speed in the direction of a slide

	- Slideboosts are triggered when you slide above a speed threshold (This threshhold can be exceeded by walking in a straight line)

	- Unlike Slideboosts in TF2 (which operate on a cooldown), these operate as more of a "one time use"

	- When you slideboost, you temporarily lose the ability to slideboost until you go below the speed threshold again

	- These are actually really mid I just made acceleration faster when you're at a standstill instead and it feels good

	- Actually fuck sliding it's mid????

# Wallruns
 	- When you start a wallrun, you get a small upwards boost (TF2)

	- Subsequent wallruns must be either at a different angle to the previous one, or sufficiently lower on the wall than the previous one
	- OR: wallruns like in parkour legacy, you get one for the left arm, one for the right arm, jumping off directs you towards wish_dir. idk if im just biased but i really like this approach

	- Jumping off applies impulse in direction of normal?
	- OR: Redirect velocity towards rotated_wish_dir, like in legacy

# Misc notes
	- Wait 1 frame before changing friction type (air, gournd ectecerta) so that bunnyhopping to avoid friction is a thing you can do some game did this once and it was kind of neat (I forgor which)
