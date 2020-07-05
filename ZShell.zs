/////////////////////////////////
/// Debug Shell for ZC Quests ///
/// Alpha Version 2.1.3       ///
/// 5th July, 2020            ///
/// By: ZoriaRPG              ///
/// Requires: 2.55 Alpha 74+  ///
/////////////////////////////////
//
// v1.2   : Finished working code. now it all functions as I intend.
// v1.2.1 : Added a code comment block with examples on how to add more instructions to match_instruction(). 
// v1.2.1 : Added a sanity check to setting Link->Item[]. It now only works on inventory items. 
// v1.3.0 : Added the SAVE instruction.
// v1.4.0 : Added CREATEITEM ( cri,id,x,y )
// v1.4.0 : Added CREATENPC ( crn,id,x,y )
// v1.4.0 : Fixed bug where buffer persists through saves.
// v1.5.0 : Added LX and LY as literal args for Link's X and Y positions. 
// v1.6.0 : Added LX and LY tracing.
// v1.6.0 : Added PALETTE as pal,n1,n2 -- POS now requires more than 'p' -- to change DMap Palette. -1 for current DMap.
// v1.6.0 :       This sets Game->DmapPalette[n1] = n2
// v1.6.0 : Added MONOCHROME as mon,n to set Graphics->Monochrome(n1)
// v1.6.1 : Added break instructiosn to fix invalid rval and other invalid returns in switch statements. 
// v1.6.2 : Added clear instructions to case for NONE in switch(instr).
// v1.7.0 : Added LTRIFORCE to set if Link has the triforce for a given level as 'lt,id,true|false'
// v1.7.0 : Added LCOMPASS to set if Link has the compass for a given level as 'lc,id,true|false'
// v1.7.0 : Added LMAP to set if Link has the map for a given level as 'lm,id,true|false'
// v1.7.0 : Added LBOSSKEY to set if Link has the boss key for a given level as 'lb,id,true|false'
// v1.7.0 : Added LKEYS to set the current number of LEVEL KEYS for a given level ID as 'lk,levelid,number'
// v1.7.0 : Added BOMBS to set the current number of bombs as 'b,number'
// v1.7.0 : Added MBOMBS to set the current number of max bombs as 'b,number'
// v1.7.0 : Added ARROWS to set the current number of arrows as 'a,number'
// v1.7.0 : Added MARROWS to set the current number of max arrows as 'a,number'
// v1.7.0 : Added RUPEES to set the current number of rupees as 'r,number'
// v1.7.0 : Added MRUPEES to set the current number of max rupees as 'r,number'
// v1.7.0 : Added KEYS to set the current number of keys as 'k,number'
// v1.7.0 : Added BIGHITBOX to set the if Link's hitbox is large (full tile collision), or small, as 'h,t|f'
// v1.7.0 : Added DIAGONALMOVE to set the if Link may move diagonally, as 'd,t|f'
// v1.7.1 : orrected a bug where RUPEES was using Game->Counter[RUPEES} insead of CR_RUPEES.
// v1.7.1 : Added a NULL case for token[1] of command 'r', so that 'r' without any other legal char as the next token is RUPEES.
// v1.8.0 : Added FSCRIPT as 'fs,ffc_id,script_id'
// v1.8.0 : Added SETFFCDATA as 'fs,ffc_id,combo_id'
// v1.8.0 : Added RUNFFCSCRIPTID as 'run,script_id'
// v1.8.0 : Fixed missing break statements in execute(stack) switch(instr). 
// v1.9.0 : Added HUE as 'hu,r,g,b,t|f'
// v1.9.0 : Added TINT as 't,r,g,b'
// v1.9.0 : Added CLEARTINT as 'cl'
/* v1.10.0 : 
	Added all FFC vars:
	fc FCSET; fx FX; fy FY; fvx FVX; fvy FVY; fax FAX ; fay FAY; ffl FFLAGS; fth FTHEIGHT; ftw FTWIDTH ; feh FEHEIGHT ; few FEWIDTH
	fl FLINK; fm FMISC
	Added PLAYSOUND as 'pls,sound_id'
	Added PLAYMIDI as 'plm,midi_id'
	Added DMAPMIDI as 'dmm,dmap_id,midi_id'
*/
// v1.10.1 : Added KEY_STOP (period) to the list of legal keys, to permit floating point values.
// v1.10.1 : Fixed a bug where instructions missing params would not abort, and clear Start presses on abort().
/* v1.11.0 : 
	The key used to open the shell is now a config option, with a base setting of F7.
	Added an instruction QUEUE. You can now store up to 20 instructions. 
	Press the DOWN ARROW KEY to store an instruction.
	Press the ENTER key on an empty line to process all stored instructions.
*/
/* v1.11.1 : 
	Fixed some issues with the number of ENQUEUED instructions being offset based on whether the user tried
	to press the ENTER key on an empty line, or on a line with an instruction.
*/
/* v1.11.2 : Further patches to enqueued counts and behaviour.
	Both of these now work properly, without any error codes.
	I converted 'bool type()' into 'int type()' and now I return three possible conditions:
		NONE: The user escaped out of the shell, or there were no instructions to process on pressing ENTER.
		ENQUEUE: There are instructions in the queue.
		RAW : This is when there is only one instruction, and no prior instructions entered,
			and the user presses ENTER.
*/

// v1.12.0 : Added 'h,value' for SETLIFE.
// v1.12.0 : Added 'm,value' for SETMAGIC.
// v1.12.0 : Added 'co,counter_id,value' for SETCOUNTER.
// v1.12.0 : Changed BIGHITBOX from 'h,t|f' to 'hb,t|f'.

// v1.13.0 : Begin adding SEQUENCES to save a sequence of instructions. Added ten sequence slots.
// v1.13.0 : To save a sequence, hold CONTROL and press a main row number from 1 through 0.
// v1.13.0 : That number will be the SEQUENCE SLOT that you are using. Sequences can be saved!
// v1.13.0 : To run a sequence, open the shell and type RunSequence,id : This command is CaSe-SeNsItIvE!
// v1.13.1 : WTF? I found a parser bug. Scan the file for 'parser' to read more.
// v1.13.2 : Created a temporary work-around for the parser bug and fixed the save/read SEQUENCE functions.
// v1.13.2 : Sequences now seem to work. 
// v1.14.0 : Added TRACE as an instruction to print to log. This uses the format of:
// v1.14.0 : %s:string -- traces 'string' to the log.
// v1.14.0 : %d:value -- traces value to the log.
// v1.14.1 : Patched error in the offset of TRACE copying into temp buffers.
// v1.14.1 : Increased size of MAX_TOKEN_LENGTH from 16 to 100, to allow for strings. 
// v1.14.1 : Fixed call to atof() in TRACE for token %d
// v1.14.1 : Removed extraneous spaces and colons in strings inside calls to TrqaceError*()
// v1.14.2 : TRACE now eats all leading spaces and colons, instead of using a hardcoded offset.
// v1.14.3 : Moved a number of traces into 'if ( log_actions ) ' statements, and disabled others. 
// v1.14.4 : Fixed a bug where holding down a shift key would only modify the very next character. 
// v2.0.0  : Rewritten for 2.55. Now uses switch-case on strings, an other new parser features.
//         : Optimised; converted custom logging to internal trace and printf.
//         : The instruction set is no longer shorthand, but can be easily edited and expanded.
// v2.1.0  : Renamed a few commands, and added better documentation.
// v2.1.1  : Fixed an infinite loop hang when using backspace.
//         : Prevent the player from moving when enqueuing commands by pressing the 'down' key.
// v2.1.2  : Enabled option STRING_SWITCH_CASE_INSENSITIVE in match_instruction().
// v2.1.3  : Trace stacks on runsequence(), and minor fixes to TraceStack().



#include "std.zh"

/*
Instructions, 		Args			Description
WARP: 			dmap,screen		Warp to a specific dmap and screen.
POS			x,y			Reposition player on the screen.
MOVEX			pixels (+/-)		Move player by +/-n pixels on the X axis.
MOVEY			pixels (+/-)		Move player by +/-n pixels on the Y axis.
REFILLHP		NONE			Refill player's HP to Max.
REFILLMP		NONE			Refill player's MP to Max.
REFILLCTR		counter			Refill a specific counter to Max.
MAXHP			amount			Set player's Max HP.
MAXMP			amount			Set player's Max MP.
MAXCTR			counter, amount		Set the maximum value of a specific counter.
INVISIBLE		(BOOL) on / off		Set player's Invisible state.
INVENTORY		item, (BOOL), on / off	Set the state of a specific item in player's inventory.
BIGHITBOX		(BOOL) on / off		Set if player sprite uses a full tile hitbox. (hitbox)
DIAGONALMOVE		(BOOL) on / off		Set if player can move diagonally.

SAVE			NONE			Save the game.
CREATEITEM		id, x, y		Create an item at coordinates x, y. 
CREATENPC		id, x, y		Create an enemy at coordinates x, y.

PALETTE			dmap,pal		Change a DMap palette; -1 for current dmap.
MONOCHROME 		(BOOL) on / off		Set monochrome effect.

	
ARROWS			amount			Set the current number of Arrows
BOMBS			amount			Set the current number of Bombs
RUPEES			amount			Set the current number of Rupees
MAXBOMBS		amount			Set the current number of Max Bombs
MAXARROWS		amount			Set the current number of Max Arrows
MAXRUPEES		amount			Set the current number of Max Rupees
KEYS			amount			Set the current number of Keys
LKEYS			level id, number	Set the current number of Level Keys for a specific level ID.
LMAP			level id, (BOOL) t|f	Set if the MAP item for a specific Level is in inventory.
LCOMPASS		level id, (BOOL) t|f	Set if the COMPASS item for a specific Level is in inventory.
LTRIFORCE		level id, (BOOL) t|f	Set if the TRIFORCE item for a specific Level is in inventory.
LBOSSKEY		level id, (BOOL) t|f	Set if the BOSS KEy item for a specific Level is in inventory.

HUE			r, g, b, (BOOL) t|f	Set a specific hue effect.
TINT			r, g, b			Set a specific tint effect.
CLEARTINT		NONE			Clear hue/tint.
	
FDATA			id, combo_id		Set the Data value of one ffc.
FSCRIPT			id, scriptnumber	Set the Script value of one ffc.
FCSET 			id, cset		Set the CSet of an ffc. 
FX			id, x			Set the X component of an ffc.
FY			id, y			Set the Y component of an ffc.
FVX			id, vx			Set the X Velocity Component of an ffc.
FVY			id, vy			Set the Y Velocity Component of an ffc.
FAX 			id, ax			Set the X Accel. Component of an ffc. 
FAY			id, ay			Set the XYAccel. Component of an ffc. 
FFLAGS			id, flag, (BOOL) t|f	Set an ffc flag state true or false.
FTHEIGHT		id, tileheight		Set the TileHeight of an ffc.
FTWIDTH 		id, tilewidth		Set the TileWidth of an ffc.
FEHEIGHT 		id, effectheight	Set the EffectHeight of an ffc.
FEWIDTH			id, effectwidth		Set the EffectWidth of an ffc.
FLINK 			id, link_id		Link an ffc to another, or clear a link. 
FMISC			id, index, value	Write to the Misc[] values of an ffc.

RUNFFCSCRIPTID		scriptid		Attempt to run an ffc script.
	
PLAYSOUND 		sound_id		Play a sound effect.
PLAYMIDI 		midi_id			Play a MIDI. 
DMAPMIDI		dmap_id, midi_id	Set the MIDI for a specific DMap to a desired ID.

%D:			*number			Traces the number after :
%S:			*string			Traces all text after :

*/

namespace debugshell
{
	typedef const int CFG;
	
	//Stack and Queue
	const int INSTRUCTION_SIZE 	= 1; //The number of stack registers that any given *instruction* requires.
	const int MAX_INSTR_QUEUE 	= 20; //The number of instructions that can be enqueued. 
	const int MAX_ARGS 		= 4; //The maximum number of args that any instruction can use/require. 
	const int STACK_SIZE 		= 2 + ((INSTRUCTION_SIZE+MAX_ARGS)*MAX_INSTR_QUEUE);  //+2 now includes TOP
	const int MAX_TOKEN_LENGTH 	= 100;
	const int BUFFER_LENGTH 	= 42;
	
	const int TOP 			= ((INSTRUCTION_SIZE+MAX_ARGS)*MAX_INSTR_QUEUE)+1;
	
	const int rERROR 		= 0;
	const int rRAW 			= 1;
	const int rENQUEUED 		= 2;
	const int SEQUENCES 		= 10;
	
	//Stack global variables and arrays
	int stack[STACK_SIZE];
	int SP;
	int ENQUEUED;
	int debug_buffer[BUFFER_LENGTH];
	int sequences[(STACK_SIZE+1)*SEQUENCES];
	
	enum winstattypes 
	{
		wsNONE, wsOPEN, wsCLOSING, wsCLEANUP, wsLAST
	};
	winstattypes windowstatus;
	
	const int YES = 1;
	const int NO = 0;
	
	//Configuration
	
	//Debugging
	CFG log_actions 	= NO;
	
	//Window Settings
	
	CFG WINDOW_F_KEY 	= 53; //We use F7 to open the debug window. 
	
	CFG W_COLOUR 		= 0x03; //window colour (background), black
	CFG W_S_COLOUR 		= 0xC5; //window colour (background), black
	CFG WINDOW_X 		= 15; //window indent over screen
	CFG WINDOW_Y 		= 19; //window indent over screen
	CFG WINDOW_H 		= 50;//CHAR_WIDTH * BUFFER_LENGTH;
	CFG WINDOW_W 		= 180; //CHAR_HEIGHT * 3;
	CFG WINDOW_S_X 		= 12; //window indent over screen
	CFG WINDOW_S_Y 		= 16; //window indent over screen
	CFG WINDOW_S_H 		= 50; //CHAR_WIDTH * BUFFER_LENGTH;
	CFG WINDOW_S_W 		= 180; //CHAR_HEIGHT * 3;
	CFG W_OPACITY 		= OP_OPAQUE; //Window translucency.
	CFG W_LAYER 		= 6; //window draw layer
	
	//Font and Character Generator
	CFG FONT 		= FONT_APPLE2; //Apple II
	CFG F_COLOUR 		= 0x01; //font colour, white
	CFG F_BCOLOUR 		= -1; //font background colour, translucent
	CFG F_OPACITY 		= OP_OPAQUE; //Font translucency.
	CFG F_LAYER 		= 6; //font draw layer
	CFG CHAR_WIDTH 		= 6; //5 + one space
	CFG CHAR_HEIGHT 	= 9; //8 + one space
	CFG CHAR_X 		= 2; //Initial x indent
	CFG CHAR_Y 		= 2; //Initial y indent
	
	//Keyboard
	CFG KEY_DELAY 		= 6; //frames between keystrokes
	CFG TYPESFX = 63;
	
	//Misc
	CFG INVISIBLE_COMBO = 1;
	
	
	//Runs a saved/enqueued sequence.
	void runsequence(int id)
	{
		int seq[STACK_SIZE+1];
		ENQUEUED = sequences[(id*STACK_SIZE)+STACK_SIZE]-1; //the last value is the number of instructions that were enqueued.
		if ( log_actions ) printf("Sequence ENQUEUED is: \n",ENQUEUED);
		//int seq_max = (id*STACK_SIZE)+STACK_SIZE;
		for ( int q = 0; q < STACK_SIZE; ++q ) seq[q] = sequences[id*(STACK_SIZE+1)+q]; //copy the sequence set to the temp stack.
		if ( log_actions ) printf("Tracing sequence stack (%d)\n", seq);
		TraceStack(seq);
		execute(seq); //run the temp stack.
	}
	
	//Saves a queue.
	int savesequence(int id)
	{
		if ( log_actions ) printf("Saving sequence, ID: %d\n",id);
		//int seq_max = (id*STACK_SIZE)+STACK_SIZE;
		for ( int q = 0; q < STACK_SIZE; ++q ) 
		{
			sequences[(id*(STACK_SIZE+1))+q] = stack[q];
		}
		sequences[(id*STACK_SIZE)+STACK_SIZE] = ENQUEUED;
		ENQUEUED = 0;
		clearstack();
		abort();
		return id;
	}
	
	//Run the Interpreter on a given script
	void process()
	{
		if ( Input->ReadKey[WINDOW_F_KEY] ) //46+WINDOW_F_KEY] )
		{
			if ( log_actions ) TraceS("Enabled Debug Shell\n");
			int typeval = type(); //We want to read from the typing buffer, and store the type output. 
			switch(typeval)
			{
				case rRAW: //maybe type should be int with 0 being no return, 1 being enqueued, and 2 being raw?
				{
					if ( log_actions ) TraceS("process() evaluated type() true\n");
					unless ( ENQUEUED ) 
					{
						int r = read(debug_buffer,false);
						windowstatus = wsCLOSING;
						if ( r ) execute(stack);
					}
					else 
					{
						windowstatus = wsCLOSING;
						execute(stack);
					}
					break;
				}
				case rENQUEUED: //maybe type should be int with 0 being no return, 1 being enqueued, and 2 being raw?
				{
					if ( log_actions ) TraceS("process() evaluated type() true\n");
					--ENQUEUED;
					execute(stack);
				}
				default: 
				{
					if ( log_actions ) TraceS("type() returned: false");
					windowstatus = wsCLOSING;
					//Link->PressStart = false;
					//Link->InputStart = false;
					//Link->InputStart = false;
				}
			}
		}
	}
	
	//Process user typing
	int type()
	{
		windowstatus = wsOPEN;
		int frame = 0;
		if ( !frame && log_actions ) TraceS("Starting type()\n");
		++frame;
		Game->TypingMode = true;
		int key_timer; int buffer_pos = 0;
		bool typing = true; int e;
		Game->DisableActiveSubscreen = true;
		//while(!Input->ReadKey[KEY_ENTER] || Input->ReadKey[KEY_ENTER_PAD])
		while(typing)
		{
			if ( Input->ReadKey[KEY_BACKSPACE] ) //backspace
			{
				printf("backspace\n");
				if ( buffer_pos > 0 )
				{
					debug_buffer[buffer_pos] = 0;
					--buffer_pos;
					debug_buffer[buffer_pos] = 0;
				}
				key_timer = KEY_DELAY;
				//continue;
			}
			else if ( Input->ReadKey[KEY_DOWN] )
			{
				Link->PressDown = false;
				e = enqueue();
				if ( log_actions ) printf("type() enqueued an instruction, queue ID: %d", e);
				
			}
			else if ( Input->ReadKey[KEY_ENTER] || Input->ReadKey[KEY_ENTER_PAD] ) 
			{
				Game->TypingMode = false;
				//Link->PressStart = false;
				//TraceNL(); TraceS("Read enter key, and buffer position is: "); Trace(buffer_pos); TraceNL();
				unless ( buffer_pos ) 
				{
					unless ( ENQUEUED ) 
					{
						windowstatus = wsCLOSING;
						return 0; //do not execute if there are no commands
					}
					else return rENQUEUED;
				}
				else //we've typed something
				{
					if ( ENQUEUED ) 
					{
						e = enqueue(); return rENQUEUED; //also enqueue this line
					}
					else 
					{
						return rRAW;
						windowstatus = wsCLOSING;
					}
				}
			}
			else if ( Input->Key[KEY_LCONTROL] || Input->Key[KEY_RCONTROL] )
			{
				for ( int q = 0; q < 10; ++q )
				{
					if ( Input->ReadKey[KEY_0+q] ) { savesequence(q); return 0; }
				}
			}
			else if ( EscKey() ) 
			{
				for ( int q = 0; q < BUFFER_LENGTH; ++q ) debug_buffer[q] = 0;
				clearstack();
				
				Game->TypingMode = false;
				windowstatus = wsCLOSING;
				return 0; //exit and do not process.
			}
			
			else
			{
				//else normal key
				int k; 
				int LegalKeys[]= //wish that we had const arrays
				{
					KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, 
					KEY_I, KEY_J, KEY_K, KEY_L, KEY_M, KEY_N, KEY_O, KEY_P, 
					KEY_Q, KEY_R, KEY_S, KEY_T, KEY_U, KEY_V, KEY_W, KEY_X, 
					KEY_Y, KEY_Z, KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, 
					KEY_6, KEY_7, KEY_8, KEY_9, KEY_0_PAD, KEY_1_PAD, KEY_2_PAD, 
					KEY_3_PAD, KEY_4_PAD, KEY_5_PAD,
					KEY_6_PAD, KEY_7_PAD, KEY_8_PAD, KEY_9_PAD, KEY_STOP, //period
					KEY_TILDE, 
					KEY_MINUS, 
					KEY_EQUALS, KEY_OPENBRACE, KEY_CLOSEBRACE,
					KEY_COLON, KEY_QUOTE, KEY_BACKSLASH, KEY_BACKSLASH2, 
					KEY_COMMA, 
					KEY_SEMICOLON, KEY_SLASH, KEY_SPACE, KEY_SLASH_PAD,
					KEY_ASTERISK, 
					KEY_MINUS_PAD,
					KEY_PLUS_PAD, KEY_CIRCUMFLEX, KEY_COLON2, KEY_EQUALS_PAD, KEY_STOP 
				};

				
				for ( int kk = SizeOfArray(LegalKeys)-1; kk >= 0; --kk )
				{
					k = LegalKeys[kk];
					if ( Input->ReadKey[k] )
					{
						//TraceS("Read a key: "); Trace(k); TraceNL();
						debug_buffer[buffer_pos] = KeyToChar(k); //Warning!: Some masking may occur. :P
						//TraceNL(); TraceS(debug_buffer); TraceNL();
						++buffer_pos;
						key_timer = KEY_DELAY;
						break;
					}
				}
				
				//continue;
			}
			
			//else { --key_timer; }
			if ( e )
			{
				clearbuffer();
				buffer_pos = 0;
				e = 0;
			}
			draw();
			Waitframe();
		}
	}
	
	//Draws the Shell
	void draw()
	{
		Screen->Rectangle(W_LAYER, WINDOW_S_X, WINDOW_S_Y, WINDOW_S_X+WINDOW_W, WINDOW_S_Y+WINDOW_H, W_S_COLOUR, 1, 0,0,0,true,W_OPACITY);
		Screen->Rectangle(W_LAYER, WINDOW_X, WINDOW_Y, WINDOW_X+WINDOW_W, WINDOW_Y+WINDOW_H, W_COLOUR, 1, 0,0,0,true,W_OPACITY);
		Screen->DrawString(F_LAYER,WINDOW_X+CHAR_X,WINDOW_Y+CHAR_Y,FONT,F_COLOUR,F_BCOLOUR,0,debug_buffer,F_OPACITY);
	}
	
	void windowcleanup()
	{
		switch(windowstatus)
		{
			case wsCLOSING:
				windowstatus = wsCLEANUP; break;
			case wsCLEANUP:
				Game->DisableActiveSubscreen = false;
				windowstatus = wsNONE; break;
		}
	}
		
	
	//List of instructions
	enum instructions
	{
		//instruction	//variables
		NONE,		//NONE 
		WARP,		//dmap,screen
		POS,		//x,y
		MOVEX,		//pixels (+/-)
		MOVEY,		//pixels (+/-)
		REFILLHP,	//aNONE
		REFILLMP,	//NONE
		REFILLCTR,	//counter
		MAXHP,		//amount
		MAXMP,		//amount
		MAXCTR,		//counter, amount
		
		INVISIBLE,	//(BOOL) on / off
		INVENTORY,	//item, (BOOL), on / off
		SAVE,		//item, (BOOL), on / off
		CREATEITEM,	//item, (BOOL), on / off
		CREATENPC,	//item, (BOOL), on / off
		PALETTE,	//item, (BOOL), on / off
		MONOCHROME,	//item, (BOOL), on / off
		BOMBS,		//item, (BOOL), on / off
		MBOMBS,		//item, (BOOL), on / off
		ARROWS,		//item, (BOOL), on / off
		MARROWS,	//item, (BOOL), on / off
		KEYS,		//item, (BOOL), on / off
		LKEYS,		//item, (BOOL), on / off
		RUPEES,		//item, (BOOL), on / off
		MRUPEES,	//item, (BOOL), on / off
		LMAP,		//level map, level id, true|false
		LBOSSKEY,	//level map, level id, true|false
		BIGHITBOX,	//level map, level id, true|false
		DIAGONALMOVE,	//level map, level id, true|false
		LTRIFORCE,	//level map, level id, true|false
		LCOMPASS,	//level map, level id, true|false
		
		RUNFFCSCRIPTID,
		FSCRIPT,
		FDATA,
		
		TINT,
		HUE,
		CLEARTINT,
		
		FCSET,
		FX,
		FY,
		FVX,
		FVY,
		FAX,
		FAY,
		FFLAGS, //ffc flags
		FTHEIGHT,
		FTWIDTH,
		FEHEIGHT,
		FEWIDTH,
		FLINK,
		FMISC,
		
		PLAYSOUND,
		PLAYMIDI,
		DMAPMIDI,
		
		SETLIFE,
		SETMAGIC,
		SETCOUNTER,
		
		SAVESEQUENCE,
		RUNSEQUENCE,
		
		TRACE,
		INSTRUCTIONSEND
	};
	
	//Returns the number of args to grab from an instruction
	int num_instruction_params(int instr)
	{
		switch(instr)
		{
			//instruction		//variables
			case NONE: return 0;
			case WARP: return 2;	//dmap,screen
			case POS: return 2;		//x,y
			case MOVEX: return 1; 	//pixels (+/-)
			case MOVEY: return 1; 	//pixels (+/-)
			case REFILLHP: return 0;	//aNONE
			case REFILLMP: return 0;	//NONE
			case REFILLCTR: return 1;	//counter
			case MAXHP: return 1;	//amount
			case MAXMP: return 1;	//amount
			case MAXCTR: return 2;	//counter, amount
			
			case INVISIBLE: return 1;	//(BOOL) on / off
			case INVENTORY: return 2;	//item, (BOOL), on / off
			case SAVE: return 0;	//item, (BOOL), on / off
			case CREATEITEM: return 3;	//item, (BOOL), on / off
			case CREATENPC: return 3;	//item, (BOOL), on / off
			case PALETTE: return 2;	//item, (BOOL), on / off
			case MONOCHROME: return 1;	//item, (BOOL), on / off
			
			case BOMBS: return 1;
			case MBOMBS: return 1;
			case ARROWS: return 1;
			case MARROWS: return 1;
			case KEYS: return 1;
			case LKEYS: return 2; //level, number
			case RUPEES: return 1;
			case MRUPEES: return 1;
			case LMAP: return 2;	//level map, level id, true|false
			case LBOSSKEY: return 2;	//level bosskey, level id, true|false
			case LTRIFORCE: return 2;	//level bosskey, level id, true|false
			case LCOMPASS: return 2;	//level bosskey, level id, true|false
			case BIGHITBOX: return 1;	//true|false
			case DIAGONALMOVE: return 1;	//true|false
			case RUNFFCSCRIPTID: return 1;
			case FSCRIPT: return 2;
			case FDATA: return 2;
			
			case TINT: return 3;
			case HUE: return 4;
			case CLEARTINT: return 0;
			
			case FCSET: return 2;
			case FX: return 2;
			case FCSET: return 2;
			case FX: return 2;
			case FY: return 2;
			case FVX: return 2;
			case FVY: return 2;
			case FAX: return 2;
			case FAY: return 2;
			case FFLAGS: return 3;
			case FTHEIGHT: return 2;
			case FTWIDTH: return 2;
			case FEHEIGHT: return 2;
			case FEWIDTH: return 2;
			case FLINK: return 2;
			case FMISC: return 3;
			
			case PLAYSOUND: return 1;
			case PLAYMIDI: return 1;
			case DMAPMIDI: return 3;
			
			case SETLIFE: return 1;
			case SETMAGIC: return 1;
			case SETCOUNTER: return 2;
			
			case SAVESEQUENCE: return 1;
			case RUNSEQUENCE: return 1;
			case TRACE: return 0;
	
			default: 
			{
				
				printf("Invalid instruction %d passed to stack",instr); 
				clearbuffer(); 
				return 0;
			}
		}
	}
	
	//Match token substring to an instruction
	int match_instruction(char32 token)
	{
		#option STRING_SWITCH_CASE_INSENSITIVE on
		if ( log_actions )  
		{ 
			printf("Input token into match_instruction is: %s\n", token); 
			printf("match_instruction() token is: %s\n", token); 
		}
		
		int sc; //script command, not used at present.
		
		//check normal commands first
		switch(token)
		{
			case "WARP": return WARP;
			case "POS": return POS;
			case "MOVEX": return MOVEX;
			case "MOVEY": return MOVEY;
			case "REFILLHP": return REFILLHP;
			case "REFILLMP": return REFILLMP;
			case "REFILLCTR": return REFILLCTR;
			case "MAXHP": return MAXHP;
			case "MAXMP": return MAXMP;
			case "MAXCTR": return MAXCTR;
			case "INVISIBLE": return INVISIBLE;
			case "INVENTORY": return INVENTORY;
			case "SAVE": return SAVE;
			case "CREATEITEM": return CREATEITEM;
			case "CREATENPC": return CREATENPC;
			case "PALETTE": return PALETTE;
			case "MONOCHROME": return MONOCHROME;
			case "BOMBS": return BOMBS;
			case "MBOMBS": return MBOMBS;
			case "ARROWS": return ARROWS;
			case "MARROWS": return MARROWS;
			case "KEYS": return KEYS;
			case "LKEYS": return LKEYS;
			case "RUPEES": return RUPEES;
			case "MRUPEES": return MRUPEES;
			case "LMAP": return LMAP;
			case "LBOSSKEY": return LBOSSKEY;
			case "BIGHITBOX": return BIGHITBOX;
			case "DIAGONALMOVE": return DIAGONALMOVE;
			case "LTRIFORCE": return LTRIFORCE;
			case "LCOMPASS": return LCOMPASS;
			case "RUNFFCSCRIPTID": return RUNFFCSCRIPTID;
			case "FSCRIPT": return FSCRIPT;
			case "FDATA": return FDATA;
			case "TINT": return TINT;
			case "HUE": return HUE;
			case "CLEARTINT": return CLEARTINT;
			case "FCSET": return FCSET;
			case "FX": return FX;
			case "FY": return FY;
			case "FVX": return FVX;
			case "FVY": return FVY;
			case "FAX": return FAX;
			case "FAY": return FAY;
			case "FFLAGS": return FFLAGS;
			case "FTHEIGHT": return FTHEIGHT;
			case "FTWIDTH": return FTWIDTH;
			case "FEHEIGHT": return FEHEIGHT;
			case "FEWIDTH": return FEWIDTH;
			case "FLINK": return FLINK;
			case "FMISC": return FMISC;
			case "PLAYSOUND": return PLAYSOUND;
			case "PLAYMIDI": return PLAYMIDI;
			case "DMAPMIDI": return DMAPMIDI;
			case "SETLIFE": return SETLIFE;
			case "SETMAGIC": return SETMAGIC;
			case "SETCOUNTER": return SETCOUNTER;
			case "SAVESEQUENCE": return SAVESEQUENCE;
			case "RUNSEQUENCE": 
			{
				TraceS("Found token RunSequence\n");
				return RUNSEQUENCE;
			}
			case "TRACE": return TRACE;
			
		}
		//do trace values
		switch(token[0])
		{
			case '%':
			{
				switch(token[1])
				{
					case 's':
					case 'S':
					{
						//TraceS(token);
						int buf[MAX_TOKEN_LENGTH]; 
						//Trace(buf);
						int offset = 2; 
						for ( ; (token[offset] == ' ' || token[offset] == ':'); ++offset ) continue; //destroy leading spaces
						
						for ( int qq = offset; qq < MAX_TOKEN_LENGTH; ++qq )
						{
							buf[qq-offset] = token[qq];
						}
						printf("%s\n",buf);
						//TraceS(buf);
						return TRACE;
					}
					case 'd':
					case 'D':
					{
						int buf[MAX_TOKEN_LENGTH];
						int offset = 2; 
						for ( ; (token[offset] == ' ' || token[offset] == ':'); ++offset ) continue; //destroy leading spaces
						
						for ( int q = offset; q < MAX_TOKEN_LENGTH; ++q )
						{
							buf[q-offset] = token[q];
						} 
						int tmp = atof(buf);
						
						printf("%d\n",tmp);
						
						return TRACE;
					}
					default: printf("match_instruction(TOKEN) could not evaluate the instruction: %s\n",token); abort(); return 0;
				}
				break;
			}
		}
		//if we reach here, then we could not match the token
		printf("match_instruction(TOKEN) could not evaluate the instruction: %s\n",token); abort(); return NONE;
	}
	
	//Clears the stack
	void clearstack()
	{
		for ( int q = 0; q <= stack[TOP]; ++q ) stack[q] = 0; 
		SP = 0;
		stack[TOP] = 0;
	}
	
	//Enqueue instruction into a script, instead of instantly running it.
	int enqueue()
	{
		if ( log_actions ) TraceS("enqueue() is pushing a string.\n");
		int r = read(debug_buffer,true);
		//clearbuffer();
		++ENQUEUED;
		if ( log_actions ) 
		{
			printf("Enqueued is: %d\n", ENQUEUED);
			TraceStack();
			printf("SP is now: %d\n",SP);
		}
		return ENQUEUED;
	}
	
	//Prints the full contents of the main stack.
	void TraceStack()
	{
		for ( int q = stack[TOP]; q >= 0; --q )
		printf("Stack register [%d] had value: %d"\n, q, stack[q]);
	}
	
	//Prints the full contents of a specified stack.
	void TraceStack(int which_stack)
	{
		for ( int q = which_stack[TOP]; q >= 0; --q )
		printf("Stack (%d)\n",which_stack);

		printf("register [%d]: %d\n", , q, which_stack[q]);
	}
	
	//Aborts processing and resets out of the window.
	void abort()
	{
		clearbuffer();
		Game->TypingMode = false;
		//Link->PressStart = false;
		//Link->InputStart = false;
	}
	
	//Clears the typing buffer.
	void clearbuffer()
	{
		for ( int q = 0; q < BUFFER_LENGTH; ++q ) debug_buffer[q] = 0;
	}
	
	//Interprets an instruction line, interprets the instruction token, and then reads
	//the parameters from an instruction line and feeds them to the interpreter.
	int read(char32 str, bool enqueued)
	{
		//debug
		//if ( !enqueued ) {TraceNL(); TraceS("Starting read() with an initial buffer of: "); TraceS(str); TraceNL();}
		//else {TraceNL(); TraceS("read() is running from enqueue() with an initial buffer of: "); TraceS(str); TraceNL();}
		int token[MAX_TOKEN_LENGTH]; int input_string_pos; 
		int e; int token_pos = 0; int current_param;
		for ( input_string_pos = 0; input_string_pos < MAX_TOKEN_LENGTH; ++input_string_pos )
		{
			if (str[input_string_pos] == ',' ) { ++input_string_pos; break; }
			if (str[input_string_pos] == NULL ) break;
			
			token[token_pos] = str[input_string_pos];
			++token_pos;
			
			
			//debug
			
			//++input_string_pos; //skip the comma now. If there are no params, we'll be on NULL.
		}
		//debug
		printf("read() token: %s\n", token); 
		
		//put the instruction onto the stack.
		//Right now, we are only allowing one instruction at a time.
		//This allows for future expansion.
		stack[SP] = match_instruction(token);
		//TraceNL(); TraceS("SP is: "); Trace(stack[SP]); TraceNL(); 
		int num_params = num_instruction_params(stack[SP]);
		//TraceNL(); TraceS("Number of expected params "); Trace(num_params); TraceNL(); 
		
		if ( num_params )
		{
			if ( str[input_string_pos] == NULL ) 
			{
				//no params.
				printf("Input string is missing params. Token was: %s\n", token);
				return 0;
			}
		}
		
		++SP; //get the stack ready for the next instruction.
		stack[TOP] = SP+1;
		//push the variables onto the stack.
		while ( current_param < num_params )  //repeat this until we are out of params
			//NOT a Do loop, because some instructions have no params!
		{
			for ( token_pos = MAX_TOKEN_LENGTH-1; token_pos >= 0; --token_pos ) token[token_pos] = 0; //clear the token
			
			//copy over new token
			token_pos = 0;
			//TraceNL(); TraceS("read() is seeking for params."); TraceNL();
			int temp_max = input_string_pos+MAX_TOKEN_LENGTH;
			for ( ; input_string_pos < temp_max; ++input_string_pos )
			{
				if (str[input_string_pos] == ',' ) { ++input_string_pos; break; }
				if (str[input_string_pos] == NULL ) break;
				
				token[token_pos] = str[input_string_pos];
				++token_pos;
				
				
				//debug
				
				//++input_string_pos; //skip the comma now. If there are no params, we'll be on NULL.
			}
			/*
			while( str[input_string_pos] != ',' || str[input_string_pos] != NULL ) //|| current_param >= num_params ) //token terminates on a comma, or the end of the string
			{
				token[token_pos] = str[input_string_pos]; //store the variable into a new token
				++token_pos;
			}
			*/
			//TraceNL(); TraceS("read() is getting tval"); TraceNL();
			int tval; //value of the param
			//first check the boolean types:
			//TraceNL(); TraceS("The arg token is: "); TraceS(token); TraceNL();
			
			//if the argument is not a numeric literal:
			unless ( isNumber(token[0]) )
			{
				switch(token)
				{
					case "t":
					case "true":
					case "T":
					case "TRUE":
						tval = 1; break;
					case "f":
					case "false":
					case "F":
					case "FALSE":
						tval = 0; break;
					
					case "lx":
					case "LX":
						if ( log_actions ) printf("tval set to Link->X: %d", Link->X);
						tval = Link->X; break;
					
					case "ly":
					case "LY": 
					{
						if ( log_actions ) printf("tval set to Link->Y: %d", Link->Y);
						tval = Link->Y; break;
					}
					
					default:
					{
						//no chatacter token, but we need to check for negative numbers and decimal numbers such as .123
						switch(token[0])
						{
							case '-': tval = atof(token); break;
							case '.': tval = atof(token); break;
							
							//no matching token at all
							default: printf("Invalid token passed as an argument for instruction: %s", token); tval = 0; break;
						}
					}
				
				}
			}
			else //literals
			{
				
				tval = atof(token);
				//TraceNL(); TraceS("found a literal var of: "); Trace(tval); TraceNL();
				
			}
			//push the token value onto the stack
			stack[SP] = tval; 
		
			//now out stack looks like:
			
			//: PARAMn where n is the loop iteration
			//: PARAMn where n is the loop iteration
			//: PARAMn where n is the loop iteration
			//: INSTRUCTION
			
			++SP; //this is why the stack size must be +1 larger than the3 total number of instructions and
			//params that it can hold. 
			++current_param;
			
		} //repeat this until we are out of params
		return 1;
		
	}
	
	//void getVarValue(int str)
	//{
	//	variables[VP] = atof(str);
	//	++VP;
	//}
	
	//Executes an interpreted instrucftion from the stack. 's' is the script for enqueued/saved scripts
	void execute(int s)
	{
		if ( log_actions ) 
		{
			TraceNL(); TraceS("Stack Trace\n");
			for ( int q = stack[TOP]; q >= 0; --q )
			{
				Trace(stack[q]);
			}
		}
		
		
		//TraceNL(); TraceS("Running execute(stack)"); TraceNL();
		int reg_ptr = 0; //read the stack starting here, until we reach TOP.
		int args[MAX_ARGS];
		//evaluate the instruction:
		int instr; 
		int current_arg = 0; 
		int num_of_params = 0;
		for ( ; ENQUEUED >= 0; --ENQUEUED )
		{
			current_arg = 0; //we clear this for each enqueued instruction, so that we properly place args
					//into their positions. Otherwise, we'd be trying to store args[5] instead of [2]!
			instr = s[reg_ptr];
			++reg_ptr;
			num_of_params = num_instruction_params(instr);
			//TraceNL(); TraceS("execute(stack) expects number of args to be: "); Trace(num_of_params); TraceNL();
			for ( ; num_of_params > 0; --num_of_params )
			{
				args[current_arg] = s[reg_ptr];
				//TraceNL(); TraceS("Putting an arg on the heap. Arg value: "); Trace(args[current_arg]); TraceNL();
				++current_arg;
				++reg_ptr;
				
			}
			
			if ( log_actions ) 
			{
				printf("execute believes that the present instruction is: %d\n", instr); 
				printf("args[0] is: (%d(, args[1] is: (%d)\n", args[0], args[1]);
			}
			switch(instr)
			{
				case NONE: 
					printf("STACK INSTRUCTION IS INVALID: %d", instr); 
					Game->TypingMode = false;
					clearbuffer();
					break;
				case WARP: 
				{
					Link->Warp(args[0],args[1]); 
					if ( log_actions ) printf("Cheat System Warped Link to dmap (%d),screen (%d).\n",args[0],args[1]);
					break;
				}
				case POS: 
				{
					Link->X = args[0];
					Link->Y = args[1];
					if ( log_actions ) printf("Cheat System repositioned Link to X (%d),Y (%d)\n",args[0],args[1]);
					break;
				}
				
				case MOVEX:
				{
					Link->X += args[0];
					if ( log_actions ) printf("Cheat system moved Link on his X axis by %d\n", args[0]);
					break;
				}
				case MOVEY: 
				{
					Link->Y += args[0];
					if ( log_actions ) printf("Cheat system moved Link on his Y axis by %d\n", args[0]);
					break;
				}
				case REFILLHP: 
				{
					Link->HP =  Link->MaxHP;
					if ( log_actions ) printf("Cheat system refilled Link's HP to %d\n", Link->MaxHP);
					break; 
				}
				case REFILLMP: 
				{
					Link->MP =  Link->MaxMP;
					if ( log_actions ) printf("Cheat system refilled Link's MP to %d\n", Link->MaxHP);
					break; 
				}
				case REFILLCTR: 
				{
					Game->Counter[args[0]] =  Game->MCounter[args[0]];
					if ( log_actions ) printf("Cheat system refilled Counter %d\n", args[0]);
					break; 
				}
				case MAXHP:
				{
					Game->MCounter[CR_LIFE] = args[0];
					if ( log_actions ) printf("Cheat system set Link's Max HP to %d\n",args[0]);
					break; 
				}
				case MAXMP:
				{
					Game->MCounter[CR_MAGIC] = args[0];
					if ( log_actions ) printf("Cheat system set Link's Max MP to %d\n",args[0]);
					break; 
				}
				case MAXCTR:
				{
					Game->Counter[args[0]] = args[1];
					if ( log_actions ) printf("Cheat system refilled Counter (id: %d, amount: %d)\n",args[0],args[1]);
					break; 
				}
				
				case INVISIBLE:
				{
					Link->Invisible = (args[0]) ? true : false;
					if ( log_actions ) printf("Cheat system set Link's Invisibility state to (%s)\n", ((args[0]) ? "true" : "false"));
					break;
				}
				case INVENTORY: 
				{
					itemdata id = Game->LoadItemData(args[0]);
					if ( id->Keep )
					{
						Link->Item[args[0]] = (args[1]) ? true : false;
						if ( log_actions ) printf("Cheat system set Link's Inventory Item [%d] to state (%s)\n", args[0],((args[1]) ? "true" : "false"));
						break; 
					}
					else break;
				}
				case SAVE:
				{
					TraceS("Cheat system is saving the game.\n"); 
					clearbuffer();
					Game->Save();
					break;
				}
				case CREATEITEM:
				{
					if ( log_actions ) 
					{
						printf("Cheat system is creating item ID: %d, at x (%d), y (%d)\n", args[0], args[1], args[2]);
					}
					item cci = Screen->CreateItem(args[0]);
					cci->X = args[1];
					cci->Y = args[2];
					break;
				}
				case CREATENPC:
				{
					if ( log_actions ) 
					{
						printf("Cheat system is creating npc ID: %d, at x (%d), y (%d)\n", args[0], args[1], args[2]);
					}
					npc ccn = Screen->CreateNPC(args[0]);
					ccn->X = args[1];
					ccn->Y = args[2];
					break;
				}
				case PALETTE:
				{
					Game->DMapPalette[ (( args[0] < 0 ) ? Game->GetCurDMap() : args[0]) ] = args[1];
					break;
				}
				case MONOCHROME:
				{
					Graphics->Monochrome(args[0]); break;
				}
				case MBOMBS: Game->MCounter[CR_BOMBS] = args[0]; break;
				case BOMBS: Game->Counter[CR_BOMBS] = args[0]; break;
				case MARROWS: Game->MCounter[CR_ARROWS] = args[0]; break;
				case ARROWS: Game->Counter[CR_ARROWS] = args[0]; break;
				case KEYS: Game->Counter[CR_KEYS] = args[0]; break;
				case RUPEES: Game->Counter[CR_RUPEES] = args[0]; break;
				case MRUPEES: Game->MCounter[CR_RUPEES] = args[0]; break;
				
				case LKEYS: Game->LKeys[args[0]] = args[1]; break;
				case DIAGONALMOVE: Link->Diagonal = (args[0] ? true : false); break;
				case BIGHITBOX: Link->BigHitbox = (args[0] ? true : false); break;
				
				case LMAP: 
				{
					( args[1] ) ? (Game->LItems[args[0]] |= LI_MAP) : (Game->LItems[args[0]] ~=LI_MAP);
					break;
				}
				case LBOSSKEY: 
				{
					( args[1] ) ? (Game->LItems[args[0]] |= LI_BOSSKEY) : (Game->LItems[args[0]] ~=LI_BOSSKEY);
					break;
				}
				case LCOMPASS: 
				{
					( args[1] ) ? (Game->LItems[args[0]] |= LI_COMPASS) : (Game->LItems[args[0]] ~=LI_COMPASS);
					break;
				}
				case LTRIFORCE: 
				{
					( args[1] ) ? (Game->LItems[args[0]] |= LI_TRIFORCE) : (Game->LItems[args[0]] ~=LI_TRIFORCE);
					break;
				}
				case FDATA: 
				{
					Screen->LoadFFC(args[0])->Data = args[1];
					break;
				}
				case FSCRIPT: 
				{
					Screen->LoadFFC(args[0])->Script = args[1];
					break;
				}
				case RUNFFCSCRIPTID: 
				{
					ffc f; bool running;
					for ( int q = 1; q < 33; ++q )
					{	
						f = Screen->LoadFFC(args[0]);
						if ( !f->Script )
						{
							if ( !f->Data ) f->Data = INVISIBLE_COMBO;
							f->Script = args[1];
							running = true;
							break;
						}
					}
					if ( !running ) TraceS("Cheat system could not find a free ffc for command RUN.\n");
					break;
				}
				case CLEARTINT: 
				{
					if ( log_actions ) TraceS("Cheat shell is clearing all Tint()\n.");
					Graphics->ClearTint();
					break;
				}
				case TINT: 
				{
					if ( log_actions ) 
					{
						printf("Cheat shell is setting Tint(): R[%d], G[%d], B[%d].\n",args[0],args[1],args[2]);
					}
					
					Graphics->Tint(args[0],args[1],args[2]);
					break;
				}
				case HUE: 
				{
					if ( log_actions ) 
					{
						printf("Cheat shell is setting Hue(): R[%d], G[%d], B[%d].\n",args[0],args[1],args[2]);
						printf("Hue(distribution) is: %s\n", ( ( args[3] ) ? "true" : "false" ));
					}
					Graphics->MonochromeHue(args[0],args[1],args[2],(args[3] ? true : false));
					break;
				}
				case FCSET: 
				{
					Screen->LoadFFC(args[0])->CSet = args[1];
					break;
				}
				case FX: 
				{
					Screen->LoadFFC(args[0])->X = args[1];
					break;
				}	
				case FY: 
				{
					Screen->LoadFFC(args[0])->Y = args[1];
					break;
				}
				case FVX: 
				{
					Screen->LoadFFC(args[0])->Vx = args[1];
					break;
				}	
				case FVY: 
				{
					Screen->LoadFFC(args[0])->Vy = args[1];
					break;
				}	
				case FAX: 
				{
					Screen->LoadFFC(args[0])->Ax = args[1];
					break;
				}	
				case FAY: 
				{
					Screen->LoadFFC(args[0])->Ay = args[1];
					break;
				}	
				case FFLAGS: 
				{
					Screen->LoadFFC(args[0])->Flags[args[1]] = (args[2]);
					break;
				}	
				case FTHEIGHT: 
				{
					Screen->LoadFFC(args[0])->TileHeight = args[1];
					break;
				}	
				case FTWIDTH: 
				{
					Screen->LoadFFC(args[0])->TileWidth = args[1];
					break;
				}	
				case FEHEIGHT: 
				{
					Screen->LoadFFC(args[0])->EffectHeight = args[1];
					break;
				}	
				case FEWIDTH: 
				{
					Screen->LoadFFC(args[0])->EffectWidth = args[1];
					break;
				}	
				case FLINK: 
				{
					Screen->LoadFFC(args[0])->Link = args[1];
					break;
				}	
				case FMISC: 
				{
					Screen->LoadFFC(args[0])->Misc[args[1]] = args[2];
					break;
				}	
				
				case PLAYSOUND: Game->PlaySound(args[0]); break;
				case PLAYMIDI: Game->PlayMIDI(args[0]); break;
				case DMAPMIDI: 
				{
					
					Game->DMapMIDI[ ( (args[0] < 0) ? (Game->GetCurDMap()) : (args[0]) ) ] = args[1];
					if ( log_actions ) printf("Cheat system is setting the DMap MIDI for the DMap: [%d] to MIDI ID (%d)\n",( (args[0] < 0) ? (Game->GetCurDMap()) : (args[0]) ),args[1]); 
					break;
				}
				
				case SETLIFE: Game->Counter[CR_LIFE] = args[0]; break;
				case SETMAGIC: Game->Counter[CR_MAGIC] = args[0]; break;
				case SETCOUNTER: Game->Counter[args[0]] = args[1]; break;
					
				case RUNSEQUENCE:  printf("Running Saved Sequence:%d\n", args[0]); runsequence(args[0]); break;
				case SAVESEQUENCE: printf("Saving Sequence %d\n", savesequence(args[0])); break;
				
				case TRACE: break; //It's handled in match_instruction()
				
				default: 
				{
					
					TraceError("Invalid instruction passed to stack",instr); 
					break;
				}
				
			}
		}
		///-----later, we'll add this: //pop everything off of the stack
		//just wipe the stack for now, as we only support one command at this time
		for ( int q = 0; q <= s[TOP]; ++q ) s[q] = 0; 
		SP = 0;
		
		//clear the main buffer, too!
		for ( int cl = 0; cl < BUFFER_LENGTH; ++cl ) debug_buffer[cl] = 0;
		Game->TypingMode = false; //insurance clear
		//Link->PressStart = false;
		//Link->InputStart = false;
		ENQUEUED = 0;
		
		
	}
}

global script test
{
	void run()
	{
		debugshell::SP = 0;
		debugshell::clearbuffer();
		while(1)
		{
			debugshell::process();
			debugshell::windowcleanup();
			Waitdraw(); 
			Waitframe();
		}
		
	}
}