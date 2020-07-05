/////////////////////////////////
/// Debug Shell for ZC Quests ///
/// Alpha Version 1.14.4      ///
/// 3rd November, 2018        ///
/// By: ZoriaRPG              ///
/// Requires: ZC Necromancer  ///
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
// v1.7.0 : Added LINKDIAGONAL to set the if Link may move diagonally, as 'd,t|f'
// v1.7.1 : orrected a bug where RUPEES was using Game->Counter[RUPEES} insead of CR_RUPEES.
// v1.7.1 : Added a NULL case for token[1] of command 'r', so that 'r' without any other legal char as the next token is RUPEES.
// v1.8.0 : Added SETFFSCRIPT as 'fs,ffc_id,script_id'
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




import "std.zh"

/*
DEFINED INSTRUCTION VALUES
	w WARP: return 2;	//dmap,screen
	p POS: return 2;		//x,y
	mx MOVEX: return 1; 	//pixels (+/-)
	my MOVEY: return 1; 	//pixels (+/-)
	rh REFILLHP: return 0;	//aNONE
	rm REFILLMP: return 0;	//NONE
	rc REFILLCTR: return 1;	//counter
	mh MAXHP: return 1;	//amount
	mm MAXMP: return 1;	//amount
	mc MAXCTR: return 2;	//counter, amount
	save SAVE: return 0;	
	cri CREATEITEM: return 3;	//id, x, y
	crn CREATENPC: return 3;	//id, x, y
	
	inv INVINCIBLE: return 1;	//(BOOL) on / off
	itm LINKITEM: return 2;	//item, (BOOL), on / off
	pal PALETTE return 2
	mon MONOCHROME return 1
	
	h BIGHITBOX
	d LINKDIAGONAL
	
	a ARROWS
	b BOMBS
	r RUPEES
	mb MAXBOMBS
	ma MAXARROWS
	mr MAXRUPEES
	k KEYS
	lk LKEYS
	lm LMAP
	lc LCOMPASS
	lt LTRIFORCE
	
	hu HUE
	t TINT
	cl CLEARTINT
	
	fc FCSET 
	fx FX
	fy FY
	fvx FVX
	fvy FVY
	fax FAX 
	fay FAY
	ffl FFLAGS
	fth FTHEIGHT
	ftw FTWIDTH 
	feh FEHEIGHT 
	few FEWIDTH
	fl FLINK 
	fm FMISC
	
	pls PLAYSOUND 
	plm PLAYMIDI 
	dmm DMAPMIDI

//COMMAND LIST
	w: Warp Link to a specific dmap and screen
	p: Reposition Link on the screen.
	mx: Move link by +/-n pixels on the X axis.
	my: Move link by +/-n pixels on the Y axis.
	rh: Refill Link's HP to Max.
	rm: Refill Link's HP to Max.
	rc: Refill a specific counter to Max.
	mh: Set Link's Max HP.
	mm: Set Link's Max MP
	mc: Set the maximum value of a specific counter.
	inv: Set Link's Invisible state.
	itm: Set the state of a specific item in Link's inventory.
	save: Save the game.
	cri: Create an item.
	crn: Create an npc.
	pal: Change a DMap palette; -1 for current dmap. 
	mono: Set monochrome effect.
	
	h: Set if Link uses a full tile hitbox. (hitbox)
	d: Set if Link can move diagonally.
	
	a: Set the current number of Arrows
	b: Set the current number of Bombs
	r: Set the current number of Rupees
	mb: Set the current number of Max Bombs
	ma: Set the current number of Max Arrows
	mr: Set the current number of Max Rupees
	k: Set the current number of Keys
	lk: Set the current number of Level Keys for a specific level ID.
	lm: Set if the MAP item for a specific Level is in inventory.
	lc: Set if the COMPASS item for a specific Level is in inventory.
	lt: Set if the TRIFORCE item for a specific Level is in inventory.
	lb: Set if the BOSS KEy item for a specific Level is in inventory.
	
	fd: Set the Data value of one ffc.
	fs: Set the Script value of one ffc.
	run: Attempt to run an ffc script.
	
	hu: Set a specific hue effect.
	t: Set a specific tint effect.
	cl: Clear hue/tint.
	
	fc: Set the CSet of an ffc. 
	fx: Set the X component of an ffc.
	fy: Set the Y component of an ffc.
	fvx: Set the X Velocity Component of an ffc.
	fvy: Set the Y Velocity Component of an ffc.
	fax: Set the X Accel. Component of an ffc. 
	fay: Set the XYAccel. Component of an ffc. 
	
	ffl: Set an ffc flag state true or false.
	fth: Set the TileHeight of an ffc.
	ftw: Set the TileWidth of an ffc.
	feh: Set the EffectHeight of an ffc.
	few: Set the EffectWidth of an ffc.
	fl: Link an ffc to another, or clear a link. 
	fm: Write to the Misc[] values of an ffc.
	
	pls: Play a sound effect. 
	plm: Play a MIDI. 
	dmm: Set the MIDI for a specific DMap to a desired ID.
	
//SYNTAX
//command,args
	w,1,2
	p,1,2
	mx,1
	mx,-1
	my,1
	my,-1
	rh
	rm
	rc,1
	mh,1
	mm,1
	mc,1,2
	inv,true
	inv,false
	itm,1,true
	itm,1,false
	save
	cri,1,2,3 //id,x,y
	crn,1,2,3 //id,x,y
	pal,1,2 //dmap (-1 for current), palette
	mono,1 : mono,type
	h,true|false
	d,true|false
	
	a,1
	b,1
	r,1
	mb,1
	ma,1
	mr,1
	k,1
	lk,1,2 (level id, number)
	lm,1,t|f (level id, true|false)
	lc,1,t|f (level id, true|false)
	lt,1,t|f (level id, true|false)
	lb,1,t|f (level id, true|false)
	
	fd,1,2 (fs,ffc_id,combo_id)
	fs,1,2 (fs,ffc_id,script_id)
	run,1 (run,ffc_script_id)
	
	hu,1,2,3,t|f (hu,red,green,blue,true|false)
	t,1,2,3 (t,red,green,blue)
	cl
	
	fc,1,2 (fs,ffc_id,cset)
	fx,1,2 (fs,ffc_id,x)
	fy,1,2 (fs,ffc_id,y)
	fvx,1,2 (fs,ffc_id,vx)
	fvy,1,2 (fs,ffc_id,vy)
	fax,1,2 (fs,ffc_id,ax)
	fay,1,2 (fs,ffc_id,ay)
	
	ffl,1,2,t|f  (fs,ffc_id,flag,true|false)
	fth,1,2 (fs,ffc_id,tileheight)
	ftw,1,2 (fs,ffc_id,tilewidth)
	feh,1,2 (fs,ffc_id,effectheight)
	few,1,2 (fs,ffc_id,effectwidth)
	fl,1,2 (fs,ffc_id,link_id)
	fm,1,2,3 (fs,ffc_id,index,value)
	
	pls,1 (pls,sound_id)
	plm,1 (pls,midi_id)
	dmm,1,2 (dmm,dmap_id,midi_id)
	
		

*/

script typedef ffc namespace;
typedef const int define;
typedef const int CFG;



namespace script debugshell
{
	CFG INVISIBLE_COMBO = 1;
	
	define INSTRUCTION_SIZE = 1; //The number of stack registers that any given *instruction* requires.
	define MAX_INSTR_QUEUE = 20; //The number of instructions that can be enqueued. 
	define MAX_ARGS 	= 4; //The maximum number of args that any instruction can use/require. 
	define STACK_SIZE 	= 2 + ((INSTRUCTION_SIZE+MAX_ARGS)*MAX_INSTR_QUEUE);  //+2 now includes TOP
	define MAX_TOKEN_LENGTH = 100;
	define BUFFER_LENGTH 	= 42;
	int stack[STACK_SIZE];
	int SP;
	int ENQUEUED;
	define TOP = ((INSTRUCTION_SIZE+MAX_ARGS)*MAX_INSTR_QUEUE)+1;
	int debug_buffer[BUFFER_LENGTH];
	define rERROR = 0;
	define rRAW = 1;
	define rENQUEUED = 2;
	define SEQUENCES = 10;
	int sequences[(STACK_SIZE+1)*SEQUENCES];
	
	
	void runsequence(int id)
	{
		int seq[STACK_SIZE+1];
		ENQUEUED = sequences[(id*STACK_SIZE)+STACK_SIZE]-1; //the last value is the number of instructions that were enqueued.
		if ( log_actions ) TraceError("Sequence ENQUEUED is: ",ENQUEUED);
		//int seq_max = (id*STACK_SIZE)+STACK_SIZE;
		for ( int q = 0; q < STACK_SIZE; ++q ) seq[q] = sequences[id*(STACK_SIZE+1)+q]; //copy the sequence set to the temp stack.
		if ( log_actions ) TraceErrorS("Tracing sequence stack.", " ");
		if ( log_actions ) TraceStack(seq);
		execute(seq); //run the temp stack.
	}
	int savesequence(int id)
	{
		if ( log_actions ) TraceError("Saving sequence, ID: ",id);
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
	int sizeof(int p) { return SizeOfArray(p); }
	
	define YES = 1;
	define NO = 0;
	
	CFG log_actions = NO;
	CFG WINDOW_F_KEY = 53; //We use F7 to open the debug window. 
	
	
	define FONT = FONT_APPLE2; //Apple II
	define F_COLOUR = 0x01; //font colour, white
	define F_BCOLOUR = -1; //font background colour, translucent
	define W_COLOUR = 0x03; //window colour (background), black
	define W_S_COLOUR = 0xC5; //window colour (background), black
	define CHAR_WIDTH = 6; //5 + one space
	define CHAR_HEIGHT = 9; //8 + one space
	define WINDOW_X = 15; //window indent over screen
	define WINDOW_Y = 19; //window indent over screen
	define WINDOW_H = 50;//CHAR_WIDTH * BUFFER_LENGTH;
	define WINDOW_W = 180; //CHAR_HEIGHT * 3;
	define WINDOW_S_X = 12; //window indent over screen
	define WINDOW_S_Y = 16; //window indent over screen
	define WINDOW_S_H = 50; //CHAR_WIDTH * BUFFER_LENGTH;
	define WINDOW_S_W = 180; //CHAR_HEIGHT * 3;
	define CHAR_X = 2; //Initial x indent
	define CHAR_Y = 2; //Initial y indent
	define W_OPACITY = OP_OPAQUE; //Window translucency.
	define F_OPACITY = OP_OPAQUE; //Font translucency.
	define W_LAYER = 6; //window draw layer
	define F_LAYER = 6; //font draw layer
	
	CFG KEY_DELAY = 6; //frames between keystrokes
	
	define TYPESFX = 63;
	
	void process()
	{
		if ( Input->ReadKey[WINDOW_F_KEY] ) //46+WINDOW_F_KEY] )
		{
			if ( log_actions ) TraceS("Enabled Debug Shell");
			int typeval = type();
			if ( typeval == rRAW ) //maybe type should be int with 0 being no return, 1 being enqueued, and 2 being raw?
			{
				if ( log_actions ) TraceS("process() evaluated type() true");
				if ( !ENQUEUED ) 
				{
					int r = read(debug_buffer,false);
					if ( r ) execute(stack);
				}
				else execute(stack);
			}
			else if ( typeval == rENQUEUED ) //maybe type should be int with 0 being no return, 1 being enqueued, and 2 being raw?
			{
				if ( log_actions ) TraceS("process() evaluated type() true");
				--ENQUEUED;
				execute(stack);
			}
			else 
			{
				if ( log_actions ) TraceErrorS("type() returned: ", "false");
				Link->PressStart = false;
				Link->InputStart = false;
			}
		}
	}
	
	//if ( type() execute(stack) )
	//returns true if the user presses enter
	int type()
	{
		int frame = 0;
		if ( !frame && log_actions ) TraceS("Starting type()");
		++frame;
		Game->TypingMode = true;
		int key_timer; int buffer_pos = 0;
		bool typing = true; int e;
		//while(!Input->ReadKey[KEY_ENTER] || Input->ReadKey[KEY_ENTER_PAD])
		while(typing)
		{
			//if ( key_timer <= 0 )
			//{
				if ( Input->ReadKey[KEY_BACKSPACE] ) //backspace
				{
					
					if ( buffer_pos > 0 )
					{
						debug_buffer[buffer_pos] = 0;
						--buffer_pos;
						debug_buffer[buffer_pos] = 0;
					}
					key_timer = KEY_DELAY;
					continue;
				}
				else if ( Input->ReadKey[KEY_DOWN] )
				{
					e = enqueue();
					if ( log_actions ) TraceError("type() enqueued an instruction, queue ID: ", e);
					
				}
				else if ( Input->ReadKey[KEY_ENTER] || Input->ReadKey[KEY_ENTER_PAD] ) 
				{
					Game->TypingMode = false;
					//TraceNL(); TraceS("Read enter key, and buffer position is: "); Trace(buffer_pos); TraceNL();
					if ( !buffer_pos ) 
					{
						if ( !ENQUEUED ) return 0; //do not execute if there are no commands
						else return rENQUEUED;
					}
					else //we've typed something
					{
						if ( ENQUEUED ) 
						{
							e = enqueue(); return rENQUEUED; //also enqueue this line
						}
						else return rRAW;
					}
				}
				else if ( Input->Key[KEY_LCONTROL] || Input->Key[KEY_RCONTROL] )
				{
					if ( Input->ReadKey[KEY_0] ) { savesequence(0); return 0; }
					else if ( Input->ReadKey[KEY_1] ) { savesequence(1); return 0; }
					else if ( Input->ReadKey[KEY_2] ) { savesequence(2); return 0; }
					else if ( Input->ReadKey[KEY_3] ) { savesequence(3); return 0; }
					else if ( Input->ReadKey[KEY_4] ) { savesequence(4); return 0; }
					else if ( Input->ReadKey[KEY_5] ) { savesequence(5); return 0; }
					else if ( Input->ReadKey[KEY_6] ) { savesequence(6); return 0; }
					else if ( Input->ReadKey[KEY_7] ) { savesequence(7); return 0; }
					else if ( Input->ReadKey[KEY_8] ) { savesequence(8); return 0; }
					else if ( Input->ReadKey[KEY_9] ) { savesequence(9); return 0; }
				}
				else if ( EscKey() ) 
				{
					for ( int q = 0; q < BUFFER_LENGTH; ++q ) debug_buffer[q] = 0;
					clearstack();
					
					Game->TypingMode = false;
					return 0; //exit and do not process.
				}
				
				else
				{
					//else normal key
					int k; 
					int LegalKeys[]= 
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
							debug_buffer[buffer_pos] = KeyToChar(k,(Input->Key[KEY_LSHIFT])||(Input->Key[KEY_RSHIFT])); //Warning!: Some masking may occur. :P
							//TraceNL(); TraceS(debug_buffer); TraceNL();
							++buffer_pos;
							key_timer = KEY_DELAY;
							break;
						}
					}
					
					//continue;
				}
			//}
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
	
	void draw()
	{
		Screen->Rectangle(W_LAYER, WINDOW_S_X, WINDOW_S_Y, WINDOW_S_X+WINDOW_W, WINDOW_S_Y+WINDOW_H, W_S_COLOUR, 1, 0,0,0,true,W_OPACITY);
		Screen->Rectangle(W_LAYER, WINDOW_X, WINDOW_Y, WINDOW_X+WINDOW_W, WINDOW_Y+WINDOW_H, W_COLOUR, 1, 0,0,0,true,W_OPACITY);
		Screen->DrawString(F_LAYER,WINDOW_X+CHAR_X,WINDOW_Y+CHAR_Y,FONT,F_COLOUR,F_BCOLOUR,0,debug_buffer,F_OPACITY);
	}
	
	void TraceErrorS(int s, int s2)
	{
		TraceS(s); TraceS(": "); TraceS(s2); TraceNL();
	}
	
	void TraceError(int s, float v, float v2)
	{
		int buf[12]; int buf2[12];
		ftoa(buf,v);
		ftoa(buf2,v2);
		TraceS(s); TraceS(": "); TraceS(buf); TraceS(", "); TraceS(buf2); TraceNL();
	}
	
	void TraceErrorVS(int s, float v, int s2)
	{
		int buf[12];
		ftoa(buf,v);
		TraceS(s); TraceS(": "); TraceS(buf); TraceS(", "); TraceS(s2); TraceNL();
	}
	
	//instruction		//variables
	define NONE	= 	0;	//NONE 
	define WARP 	= 	1;	//dmap,screen
	define POS 	= 	2;	//x,y
	define MOVEX 	= 	3;	//pixels (+/-)
	define MOVEY 	= 	4;	//pixels (+/-)
	define REFILLHP = 	5;	//aNONE
	define REFILLMP = 	6;	//NONE
	define REFILLCTR = 	7;	//counter
	define MAXHP 	= 	8;	//amount
	define MAXMP 	= 	9;	//amount
	define MAXCTR 	= 	10;	//counter, amount
	
	define INVINCIBLE = 	11;	//(BOOL) on / off
	define LINKITEM = 	12;	//item, (BOOL), on / off
	define SAVE = 		13;	//item, (BOOL), on / off
	define CREATEITEM = 	14;	//item, (BOOL), on / off
	define CREATENPC = 	15;	//item, (BOOL), on / off
	define PALETTE = 	16;	//item, (BOOL), on / off
	define MONOCHROME = 	17;	//item, (BOOL), on / off
	define BOMBS = 		18;	//item, (BOOL), on / off
	define MBOMBS = 	19;	//item, (BOOL), on / off
	define ARROWS = 	20;	//item, (BOOL), on / off
	define MARROWS = 	21;	//item, (BOOL), on / off
	define KEYS = 		22;	//item, (BOOL), on / off
	define LKEYS = 		23;	//item, (BOOL), on / off
	define RUPEES = 	24;	//item, (BOOL), on / off
	define MRUPEES = 	25;	//item, (BOOL), on / off
	define LMAP = 		26;	//level map, level id, true|false
	define LBOSSKEY = 	27;	//level map, level id, true|false
	define BIGHITBOX = 	28;	//level map, level id, true|false
	define LINKDIAGONAL = 	29;	//level map, level id, true|false
	define LTRIFORCE = 	30;	//level map, level id, true|false
	define LCOMPASS = 	31;	//level map, level id, true|false
	define RUNFFCSCRIPTID = 32;
	define SETFFSCRIPT = 	33;
	define SETFFDATA = 	34;
	
	define TINT = 		35;
	define HUE = 		36;
	define CLEARTINT = 	37;
	
	define FCSET =		38;
	define FX =		39;
	define FY =		40;
	define FVX =		41;
	define FVY =		42;
	define FAX =		43;
	define FAY =		44;
	define FFLAGS =		45; //ffc flags
	define FTHEIGHT =	46;
	define FTWIDTH =	47;
	define FEHEIGHT =	48;
	define FEWIDTH =	49;
	define FLINK =		50;
	define FMISC =		51;
	
	define PLAYSOUND =	52;
	define PLAYMIDI =	53;
	define DMAPMIDI =	54;
	
	define SETLIFE =	55;
	define SETMAGIC =	56;
	define SETCOUNTER =	57;
	
	define SAVESEQUENCE =	58;
	define RUNSEQUENCE =	59;
	
	define TRACE =		60;
	
	
	
	
	
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
			
			case INVINCIBLE: return 1;	//(BOOL) on / off
			case LINKITEM: return 2;	//item, (BOOL), on / off
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
			case LINKDIAGONAL: return 1;	//true|false
			case RUNFFCSCRIPTID: return 1;
			case SETFFSCRIPT: return 2;
			case SETFFDATA: return 2;
			
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
				
				TraceError("Invalid instruction passed to stack",instr); 
				clearbuffer(); 
				return 0;
			}
		}
	}
	
	
	
	int match_instruction(int token)
	{
		if ( log_actions )  {TraceNL(); TraceS("Input token into match_instruction is: "); TraceS(token); TraceNL();}
		
		if ( log_actions ) {TraceNL(); TraceErrorS("match_instruction() token is: ",token); TraceNL();}
		if ( log_actions ) {TraceNL(); TraceError("Matching string with strcmp to 'w': ", strcmp(token,"w")); TraceNL();}
		
		/* ONE WAY TO DO THIS. I did this with individual characters, and switches, to minimise the checks down
		to the absolute minimum. -Z
		
		You could add specific instructions this way, if you wish. 
		
		if ( !(strcmp(token,"w") ) ) TraceErrorS("Token in match_instruction() matched to WARP. Token: ", token);
		if ( !(strcmp(token,"W") ) ) TraceErrorS("Token in match_instruction() matched to WARP. Token: ", token);
		if ( !(strcmp(token,"p") ) ) TraceErrorS("Token in match_instruction() matched to POS. Token: ", token);
		if ( !(strcmp(token,"P") ) ) TraceErrorS("Token in match_instruction() matched to POS. Token: ", token);
		if ( !(strcmp(token,"rh") ) ) TraceErrorS("Token in match_instruction() matched to REFILLHP. Token: ", token);
		if ( !(strcmp(token,"RH") ) ) TraceErrorS("Token in match_instruction() matched to REFILLHP. Token: ", token);
		if ( !(strcmp(token,"Rh") ) ) TraceErrorS("Token in match_instruction() matched to REFILLHP. Token: ", token);
		if ( !(strcmp(token,"rH") ) ) TraceErrorS("Token in match_instruction() matched to REFILLHP. Token: ", token);
		if ( !(strcmp(token,"rH") ) ) TraceErrorS("Token in match_instruction() matched to REFILLHP. Token: ", token);
		*/
		
		/* Putting BRACES here causes Invalid pointer errors?! PARSER BUG!!
		it works just find without the braces!!
		if ( !(strcmp(token,"RunSequence") ) ) 
		{
			TraceErrorS("Found token RunSequence", token); // return RUNSEQUENCE; }//TraceErrorS("Token in match_instruction() matched to POS. Token: ", token);
		}
		*/
			//if ( !(strcmp(token,"RunSequence") ) ) { TraceError("Found token RunSequence", " "); return RUNSEQUENCE; }
		//if ( !(strcmp(token,"SaveSequence") ) ) return SAVESEQUENCE;
		
		int sc;
		if ( !(strcmp(token,"RunSequence") ) ) sc = RUNSEQUENCE;
		if ( sc == RUNSEQUENCE ) { TraceError("Found token RunSequence", " "); return RUNSEQUENCE;}
		
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
						TraceErrorS("Log",buf);
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
						
						TraceError("Log",tmp);
						
						return TRACE;
					}
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
				break;
			}
			//A
			case 'a':
			case 'A':
				return ARROWS;
			//B
			case 'b':
			case 'B':
			{
				return BOMBS;
				/*
				switch(token[1])
				{
					case 'i':
					case 'I':
						return BIGHITBOX;
					case 'o':
					case 'O':
						return BOMBS;
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
				*/
			}
			case 'c':
			case 'C':
			{
				switch(token[1])
				{
					case NULL:
					case 'o':
					case 'O':
						return SETCOUNTER;
					case 'l':
					case 'L':
						return CLEARTINT;
					case 'r':
					case 'R':
					{
						switch(token[2])
						{
							case 'i':
							case 'I':
							{
								//TraceNL(); TraceS("instr() found token 'cri'"); TraceNL(); 
								return CREATEITEM;
							}
							
							case 'n':
							case 'N':
							{
								//TraceNL(); TraceS("instr() found token 'cri'"); TraceNL(); 
								return CREATENPC;
							}
				
							default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
						}
					}
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
				break;
			}
			//D
			case 'd':
			case 'D':
			{
				switch(token[1])
				{
					case NULL:
					case 'i':
					case 'I':
						return LINKDIAGONAL;
					case 'm':
					case 'M': //dmap stuff
					{
						switch(token[2])
						{
							
							case NULL: 
							case 'm':
							case 'M':
								return DMAPMIDI;
							default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				
						}
					}	
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				
				}
				break;
			}
			//E
			//F
			case 'f':
			case 'F':
			{
				switch(token[1])
				{
					case 'a':
					case 'A':
					{
						switch(token[2])
						{
							case 'x':
							case 'X':
								return FAX;
							case 'Y':
							case 'y':
								return FAY;
							default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				
						}
						break;
						
					}
					case 'c':
					case 'C':
						return FCSET;
					case 'd':
					case 'D':
						return SETFFDATA;
					case 'e':
					case 'E':
					{
						switch(token[2])
						{
							case 'h':
							case 'H':
								return FEHEIGHT;
							case 'w':
							case 'W':
								return FEWIDTH;
							default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
						}
						break;
					}
					case 'f':
					case 'F':
					{
						switch(token[2])
						{
							case NULL:
							case 'l':
							case 'L':
								return FFLAGS;
							
								
							default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
						}
						break;
						
					}
					case 'l':
					case 'L':
						return FLINK;
					case 'M':
					case 'm':
						return FMISC;
					case 'S':
					case 's':
						return SETFFSCRIPT;
					case 't':
					case 'T':
					{
						switch(token[2])
						{
							case 'H':
							case 'h':
								return FTHEIGHT;
							case 'w':
							case 'W':
								return FTWIDTH;
							default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
						}
						break;
						
					}
					case 'v':
					case 'V':
					{
						switch(token[2])
						{
							case 'x':
							case 'X':
								return FVX;
							case 'y':
							case 'Y':
								return FVY;
							default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
						}
						break;
						
					}
					case 'x':
					case 'X':
						return FX;
					case 'y':
					case 'Y':
						return FY;
					
					
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
				break;
			}
			//G
			//H
			case 'h':
			case 'H':
			{
				switch(token[1])
				{
					case NULL: 
						return SETLIFE;
					case 'b':
					case 'B':
						return BIGHITBOX;
					case 'u':
					case 'U':
						return HUE;
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
			}
			//I
			case 'i':
			case 'I':
			{
				switch(token[1])
				{
					case 'n':
					case 'N':
						return INVINCIBLE;
					case 't':
					case 'T':
						return LINKITEM;
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
				break;
			}
			//J
			//K
			case 'k':
			case 'K':
				return KEYS;
			//L
			case 'l':
			case 'L':
			{
				switch(token[1])
				{
					case 'b':
					case 'B':
						return LBOSSKEY;
					case 'c':
					case 'C':
						return LCOMPASS;
					case 'K':
					case 'k':
						return LKEYS;
					case 'M':
					case 'm':
						return LMAP;
					case 't':
					case 'T':
						return LTRIFORCE;
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
				
			}
			//M
			case 'm':
			case 'M':
			{
				switch(token[1])
				{
					case NULL:
						return SETMAGIC;
					case 'x':
					case 'X':
						//TraceNL(); TraceS("instr() found token 'mx'"); 
						return MOVEX;
					case 'y':
					case 'Y':
						//TraceNL(); TraceS("instr() found token 'my'"); 
						return MOVEY;
					case 'h':
					case 'H':
						return MAXHP;
					case 'm':
					case 'M':
						return MAXMP;
					case 'c':
					case 'C':
						return MAXCTR;
					case 'o':
					case 'O':
						return MONOCHROME;
					case 'b':
					case 'B': 
						return MBOMBS;
					
					case 'a':
					case 'A':
						return MARROWS;
					case 'R':
					case 'r':
						return MRUPEES;
					
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
				break;
			}
			
			//P
			case 'p':
			case 'P':
			{
				switch(token[1])
				{
					
					case 'a':
					case 'A':
						//TraceNL(); TraceS("instr() found token 'p'"); TraceNL(); 
						return PALETTE; 
					
					case 'l':
					case 'L':
					{
						switch(token[2])
						{
							case 'm':
							case 'M':
								return PLAYMIDI;
							case 's':
							case 'S':
								return PLAYSOUND;
							
							default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
						}
					}
					case 'o':
					case 'O':
						//TraceNL(); TraceS("instr() found token 'pos'"); TraceNL(); 
						return POS; 
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
				break;
			}
			//Q
			//R
			case 'r':
			case 'R':
			{
				switch(token[1])
				{
					case NULL:
						return RUPEES;
					case 'h':
					case 'H':
						return REFILLHP;
					case 'm':
					case 'M':
						return REFILLMP;
					case 'c':
					case 'C':
						return REFILLCTR;
					case 'U':
					case 'u':
					{
						switch(token[2])
						{
							case NULL:
								return RUPEES;
							case 'n':
							case 'N':
								return RUNFFCSCRIPTID;
							default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
						}
					}
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
				break;
			}
			//S
			case 's':
			case 'S':
			{
				switch(token[1])
				{
					case 'a':
					case 'A':
					case 'V':
					case 'v':
					{
						//TraceNL(); TraceS("instr() found token 'save'"); 
						return SAVE;
					}
					default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
				}
				break;
			}
			//T
			case 't':
			case 'T':
				return TINT;
			//U
			//V
			//W
			case 'w':
			case 'W':
				//TraceNL(); TraceS("instr() found token 'w'"); TraceNL(); 
				return WARP;
			
			default: TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); abort(); return 0;
		}
		
		//if ( strcmp(token,"w") == 0) { TraceNL(); TraceS("instr() found token 'w'"); return WARP; }
		//else if ( strcmp(token,"p") == 0) { TraceNL(); TraceS("instr() found token 'p'"); return POS; }
		//else if ( strcmp(token,"mx") == 0) { TraceNL(); TraceS("instr() found token 'mx'"); return MOVEX; }
		//else if ( strcmp(token,"my") == 0) return MOVEY;
		//else if ( strcmp(token,"rh") == 0) return REFILLHP;
		//else if ( strcmp(token,"rm") == 0) return REFILLMP;
		//else if ( strcmp(token,"rc") == 0) return REFILLCTR;
		//else if ( strcmp(token,"mh") == 0) return MAXHP;
		//else if ( strcmp(token,"mm") == 0) return MAXMP;
		//else if ( strcmp(token,"mc") == 0) return MAXCTR;
		//else if ( strcmp(token,"inv") == 0) return INVINCIBLE;
		//else// if ( strcmp(token,"itm") == 0) return LINKITEM;
		//else
		//{
		//	TraceErrorS("match_instruction(TOKEN) could not evaluate the instruction",token); 
		//	return 0;
		//}
	}
	void clearstack()
	{
		for ( int q = 0; q <= stack[TOP]; ++q ) stack[q] = 0; 
		SP = 0;
		stack[TOP] = 0;
	}
	int enqueue()
	{
		if ( log_actions ) TraceErrorS("enqueue() is pushing a string.", " ");
		int r = read(debug_buffer,true);
		//clearbuffer();
		++ENQUEUED;
		if ( log_actions ) TraceError("Enqueued is: ", ENQUEUED);
		if ( log_actions ) TraceStack();
		if ( log_actions ) TraceError("SP is now: ",SP);
		return ENQUEUED;
	}
	void TraceStack()
	{
		for ( int q = stack[TOP]; q >= 0; --q )
		TraceError("Stack register and value: ", q, stack[q]);
	}
	void TraceStack(int s)
	{
		for ( int q = s[TOP]; q >= 0; --q )
		TraceError("Stack register and value: ", q, s[q]);
	}
	void abort()
	{
		clearbuffer();
		Game->TypingMode = false;
		Link->PressStart = false;
		Link->InputStart = false;
	}
	void clearbuffer()
	{
		for ( int q = 0; q < BUFFER_LENGTH; ++q ) debug_buffer[q] = 0;
	}
	int read(int str, bool enqueued)
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
		TraceNL(); TraceS("read() token: "); TraceS(token); TraceNL();
		
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
				TraceErrorS("Input string is missing params. Token was", token);
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
			if ( !isNumber(token[0]) )
			{
				switch(token[0])
				{
					
					case '-': tval = atof(token); break;
					case '.': tval = atof(token); break;
					
					case 't':
					case 'T':
						tval = 1; break;
					case 'f':
					case 'F':
						tval = 0; break;
					
					case 'l':
					case 'L':
					{
						switch(token[1])
						{
							case 'x':
							case 'X':
							{
								if ( log_actions ) TraceError("tval set to Link->X: ", Link->X);
								tval = Link->X; break;
							}
							case 'y':
							case 'Y': 
							{
								if ( log_actions ) TraceError("tval set to Link->Y: ", Link->Y);
								tval = Link->Y; break;
							}
							default: TraceErrorS("Invalid token passed as an argument for instruction: ", token); tval = 0; break;
						}
						break;
					}
					
					default: TraceErrorS("Invalid token passed as an argument for instruction: ", token); tval = 0; break;
				}
				//if ( strcmp(token,"true") ) tval = 1;
				//else if ( strcmp(token,"T") ) tval = 1;
				//else if ( strcmp(token,"false") ) tval = 0;
				//else if ( strcmp(token,"F") ) tval = 0;
				
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
	
	void execute(int s)
	{
		if ( log_actions ) 
		{
			TraceNL(); TraceS("Stack Trace");
			for ( int q = stack[TOP]; q >= 0; --q )
			{
				TraceNL(); Trace(stack[q]);
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
				TraceNL(); TraceS("execute believes that the present instruction is: "); Trace(instr); TraceNL();
				TraceNL(); TraceS("args[0] is: "); Trace(args[0]); TraceNL();
				TraceNL(); TraceS("args[1] is: "); Trace(args[1]); TraceNL();
			}
			switch(instr)
			{
				case NONE: 
				TraceError("STACK INSTRUCTION IS INVALID: ", instr); 
				Game->TypingMode = false;
				clearbuffer();
				break;
				case WARP: 
				{
					Link->Warp(args[0],args[1]); 
					if ( log_actions ) TraceError("Cheat System Warped Link to dmap,screen",args[0],args[1]);
					break;
				}
				case POS: 
				{
					Link->X = args[0];
					Link->Y = args[1];
					if ( log_actions ) TraceError("Cheat System repositioned Link to X,Y",args[0],args[1]);
					break;
				}
				
				case MOVEX:
				{
					Link->X += args[0];
					if ( log_actions ) TraceError("Cheat system moved Link on his X axis by", args[0]);
					break;
				}
				case MOVEY: 
				{
					Link->Y += args[0];
					if ( log_actions ) TraceError("Cheat system moved Link on his Y axis by", args[0]);
					break;
				}
				case REFILLHP: 
				{
					Link->HP =  Link->MaxHP;
					if ( log_actions ) TraceError("Cheat system refilled Link's HP to", Link->MaxHP);
					break; 
				}
				case REFILLMP: 
				{
					Link->MP =  Link->MaxMP;
					if ( log_actions ) TraceError("Cheat system refilled Link's MP to", Link->MaxHP);
					break; 
				}
				case REFILLCTR: 
				{
					Game->Counter[args[0]] =  Game->MCounter[args[0]];
					if ( log_actions ) TraceError("Cheat system refilled Counter", args[0]);
					break; 
				}
				case MAXHP:
				{
					Game->MCounter[CR_LIFE] = args[0];
					if ( log_actions ) TraceError("Cheat system set Link's Max HP to",args[0]);
					break; 
				}
				case MAXMP:
				{
					Game->MCounter[CR_MAGIC] = args[0];
					if ( log_actions ) TraceError("Cheat system set Link's Max MP to",args[0]);
					break; 
				}
				case MAXCTR:
				{
					Game->Counter[args[0]] = args[1];
					if ( log_actions ) TraceError("Cheat system refilled Counter (id, amount)",args[0],args[1]);
					break; 
				}
				
				case INVINCIBLE:
				{
					if ( args[0] )
					{
						Link->Invisible = true;
						if ( log_actions ) TraceErrorS("Cheat system set Link's Invisibility state to ","true");
						break; 
					}
					else
					{
						Link->Invisible = false;
						if ( log_actions ) TraceErrorS("Cheat system set Link's Invisibility state to ","false");
						break; 
						
					}
					
				}
				case LINKITEM: 
				{
					itemdata id = Game->LoadItemData(args[0]);
					if ( id->Keep )
					{
						if ( args[1] )
						{
							
							Link->Item[args[0]] = true;
							if ( log_actions ) TraceErrorS("Cheat system set Link's Inventory Item to (item, state)","true");
							break; 
						}
						else
						{
							Link->Item[args[0]] = false;
							if ( log_actions ) TraceErrorS("Cheat system set Link's Inventory Item to (item, state)","false");
							break; 
							
						}
					}
					else break;
				}
				case SAVE:
				{
					TraceNL(); TraceS("Cheat system is saving the game."); 
					clearbuffer();
					Game->Save();
					break;
				}
				case CREATEITEM:
				{
					if ( log_actions ) TraceError("Cheat system is creating item ID: ", args[0]);
					if ( log_actions ) TraceError("Cheat system is creating item at X Position: ", args[1]);
					if ( log_actions ) TraceError("Cheat system is creating item at Y Position: ", args[2]);
					item cci = Screen->CreateItem(args[0]);
					cci->X = args[1];
					cci->Y = args[2];
					break;
				}
				case CREATENPC:
				{
					if ( log_actions ) TraceError("Cheat system is creating npc ID: ", args[0]);
					if ( log_actions ) TraceError("Cheat system is creating npc at X Position: ", args[1]);
					if ( log_actions ) TraceError("Cheat system is creating npc at Y Position: ", args[2]);
					npc ccn = Screen->CreateNPC(args[0]);
					ccn->X = args[1];
					ccn->Y = args[2];
					break;
				}
				case PALETTE:
				{
					if ( args[0] < 0 )
					{
						Game->DMapPalette[Game->GetCurDMap()] = args[1];
					}
					else Game->DMapPalette[args[0]] = args[1];
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
				case LINKDIAGONAL: Link->Diagonal = Cond(args[0],true,false); break;
				case BIGHITBOX: Link->BigHitbox = Cond(args[0],true,false); break;
				
				case LMAP: 
				{
					if ( args[1] ) //true
					{	
						Game->LItems[args[0]] |= LI_MAP;
					}
					else Game->LItems[args[0]] &= ~LI_MAP;
					break;
				}
				case LBOSSKEY: 
				{
					if ( args[1] ) //true
					{	
						Game->LItems[args[0]] |= LI_BOSSKEY;
					}
					else Game->LItems[args[0]] &= ~LI_BOSSKEY;
					break;
				}
				case LCOMPASS: 
				{
					if ( args[1] ) //true
					{	
						Game->LItems[args[0]] |= LI_COMPASS;
					}
					else Game->LItems[args[0]] &= ~LI_COMPASS;
					break;
				}
				case LTRIFORCE: 
				{
					if ( args[1] ) //true
					{	
						Game->LItems[args[0]] |= LI_TRIFORCE;
					}
					else Game->LItems[args[0]] &= ~LI_TRIFORCE;
					break;
				}
				case SETFFDATA: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->Data = args[1];
					break;
				}
				case SETFFSCRIPT: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->Script = args[1];
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
					if ( !running ) TraceError("Cheat system could not find a free ffc for command RUN. Try FS,id,scriptid instead.",NULL);
					break;
				}
				case CLEARTINT: 
				{
					if ( log_actions ) TraceError("Cheat shell is clearing all Tint().",NULL);
					Graphics->ClearTint();
					break;
				}
				case TINT: 
				{
					if ( log_actions ) 
					{
						TraceError("Cheat shell is setting Tint().",NULL);
						TraceError("Tint(red) is: ",args[0]);
						TraceError("Tint(green) is: ",args[1]);
						TraceError("Tint(blue) is: ",args[2]);
					}
					
					Graphics->Tint(args[0],args[1],args[2]);
					break;
				}
				case HUE: 
				{
					if ( log_actions ) 
					{
						TraceError("Cheat shell is setting Hue().",NULL);
						TraceError("Hue(red) is: ",args[0]);
						TraceError("Hue(green) is: ",args[1]);
						TraceError("Hue(blue) is: ",args[2]);
						if ( args[3] ) TraceErrorS("Hue(distribution) is: ","true");
						else TraceErrorS("Hue(distribution) is: ","false");
					}
					
					Graphics->MonochromeHue(args[0],args[1],args[2],Cond(args[3],true,false));
					break;
				}
				case FCSET: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->CSet = args[1];
					break;
				}
				case FX: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->X = args[1];
					break;
				}	
				case FY: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->Y = args[1];
					break;
				}
				case FVX: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->Vx = args[1];
					break;
				}	
				case FVY: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->Vy = args[1];
					break;
				}	
				case FAX: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->Ax = args[1];
					break;
				}	
				case FAY: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->Ay = args[1];
					break;
				}	
				case FFLAGS: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->Flags[args[1]] = (args[2]);
					break;
				}	
				case FTHEIGHT: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->TileHeight = args[1];
					break;
				}	
				case FTWIDTH: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->TileWidth = args[1];
					break;
				}	
				case FEHEIGHT: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->EffectHeight = args[1];
					break;
				}	
				case FEWIDTH: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->EffectWidth = args[1];
					break;
				}	
				case FLINK: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->Link = args[1];
					break;
				}	
				case FMISC: 
				{
					ffc f = Screen->LoadFFC(args[0]);
					f->Misc[args[1]] = args[2];
					break;
				}	
				
				case PLAYSOUND: Game->PlaySound(args[0]); break;
				case PLAYMIDI: Game->PlayMIDI(args[0]); break;
				case DMAPMIDI: 
				{
					if ( args[0] < 0 ) 
					{ 
						if ( log_actions ) TraceError("Cheat system is setting the DMap MIDI for the current DMap to: ",args[1]); 
						Game->DMapMIDI[Game->GetCurDMap()] = args[1]; 
					}
					
					else
					{ 
						if ( log_actions ) TraceError("Cheat system is setting the DMap MIDI for the DMap: ",args[0]); 
						if ( log_actions ) TraceError("...to MIDI ID: ",args[1]); 
						Game->DMapMIDI[args[0]] = args[1];
					}
					break;
				}
				
				case SETLIFE: Game->Counter[CR_LIFE] = args[0]; break;
				case SETMAGIC: Game->Counter[CR_MAGIC] = args[0]; break;
				case SETCOUNTER: Game->Counter[args[0]] = args[1]; break;
					
				
				case RUNSEQUENCE: { TraceError("Running Saved Sequence", args[0]); runsequence(args[0]); break; }
				case SAVESEQUENCE: TraceError("Saving Sequence", savesequence(args[0])); break;
				
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
		Link->PressStart = false;
		Link->InputStart = false;
		ENQUEUED = 0;
		
		
	}
		
	void run()
	{
	
		
		
	}
}

global script test
{
	void run()
	{
		debugshell.SP = 0;
		debugshell.clearbuffer();
		while(1)
		{
			debugshell.process();
			Waitdraw(); 
			Waitframe();
		}
		
	}
}