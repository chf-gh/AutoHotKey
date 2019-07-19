
#HotkeyModifierTimeout -1
SetKeyDelay ,-1
SetStoreCapslockMode, off

CapsLock::Send, ^{Space}
^CapsLock::Send {CapsLock}    

$e::d
$r::f
$t::j
$y::k
$u::u
$i::r
$o::l
$d::e
$f::t
$h::y
$j::n
$k::i
$l::o 
$n::p
$`;::h
$p::`;
 
 

 
; 打开所有卡片 
#w::
	;如果窗口已经打开则选中
	IfWinExist, 所有卡片
	{
		WinActivate  ; 自动使用上面找到的窗口.   
		return
	}
	; 创建含名称和大小两列的 ListView:
	Gui, Add, ListView,AltSubmit r30   x0 y0 gMyListView vListView   SortDesc c222222 Grid ,  Name|create_date
	Gui, Add, Text, w400 x+2 r1 , 内容:
	Gui, Add, Edit, w700 y+2 r34 vItemContent , 未选择行
	Gui, Add, Button, w100 x+-100 y+4 , Update    ; ButtonUpdate(如果存在)会在此按钮被按下时运行.
	Gui, Add, Button, w100 x+-600 y+-22 , Delete     
	Gui, +Resize  ; 让用户可以调整窗口的大小. 
	Gui, Font, s10 cBlack , Verdana  ; 如果需要, 使用这样的一行给窗口设置新的默认字体.
    GuiControl, Font, ItemContent  ; 让上面的字体设置对控件生效.
    GuiControl, Font, ListView  ; 让上面的字体设置对控件生效.
	; 文件路径
	addr=D:\card
	
	Loop, %addr%\*.*  
	{  
		FormatTime, time, %A_LoopFileTimeCreated%,yyyy-MM-dd 
		LV_Add( , A_LoopFileName, time) ;去除参数序号A_Index,  
	}
	LV_ModifyCol( )  ; 根据内容自动调整每列的大小. 
	LV_ModifyCol(1  ,"  Sort")  ; 
	;LV_ModifyCol(2  ,"  SortDesc","Date")  ; 为了进行排序, 指出列 2 是整数. 去掉了时间排序
	 ;选中行
	LV_Modify(1, "Select")
	LV_Modify(1, "Focus")

	RowText=""
	preNum = 0 ;切换标题前的标题行号
	preText = "" ;切换标题前的标题 
	; 显示窗口并返回. 每当用户点击一行时脚本会发出通知.
	Gui, Show, ,所有卡片--%addr%
	return
	  
	GuiClose:
	GuiEscape: 	 
		preNum = 0 ;切换标题前的标题行号
		preText = "" ;切换标题前的标题 
		if("" != RowText){  
			GuiControlGet, ItemContent  ; 获取编辑控件的内容. 
			FileDelete, %addr%\%RowText% 			
			FileAppend,%ItemContent%,  %addr%\%RowText%   
			Gui, Submit, NoHide  ; 保存用户的输入到每个控件的关联变量中   
		}
		Gui Destroy  ; 销毁关于对话框.  
	return		
	MyListView: 
			if preNum != 0 
			{   
				LV_GetText(preText, preNum, 1) ; 获取首个字段的文本.   
				if("" != preText){  
					GuiControlGet, ItemContent  ; 获取编辑控件的内容. 
					FileDelete, %addr%\%preText% 			
					FileAppend,%ItemContent%,  %addr%\%preText%   
					Gui, Submit, NoHide  ; 保存用户的输入到每个控件的关联变量中   
					  
				}else{
					MsgBox,0,,保存上一个内容失败    
				}
			}  
			FocusedRowNumber := LV_GetNext( , "F")  ; 查找焦点行. 
			if not FocusedRowNumber  ; 没有焦点行.
				return
			LV_GetText(RowText, FocusedRowNumber, 1) ; 获取首个字段的文本.
			FileRead, FileContents, %addr%\%RowText%
			GuiControl,, ItemContent, %FileContents%  
			GuiControl,Focus,ItemContent
			preNum = %FocusedRowNumber%;  
			 
	return 
	ListViewClick: 
		MsgBox,0,,单击  %A_GuiEvent%
	return
	
	;tooltip函数
	RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
	return
	
	ButtonUpdate: 
		if("" != RowText){  
			GuiControlGet, ItemContent  ; 获取编辑控件的内容. 
			FileDelete, %addr%\%RowText% 			
			FileAppend, %ItemContent%  `n,  %addr%\%RowText%   
			Gui, Submit, NoHide  ; 保存用户的输入到每个控件的关联变量中  
			ToolTip ,修改成功 
			SetTimer, RemoveToolTip, 1000 
			return  
		}else{
			MsgBox,0,,无内容   
			return  
		}		
	return 
	ButtonDelete:  
		if("" != RowText){ 
			MsgBox,292,,确定删除: %RowText% 这个卡片吗？    
			IfMsgBox No
				return 
			; 删除列表中的行
			Loop
			{
				RowNumber := LV_GetNext(RowNumber - 1)  ; 在前一次找到的位置后继续搜索.
				if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
					break
				LV_Delete(  RowNumber) 
			}
			; 删除文件
			GuiControlGet, ItemContent  ; 获取编辑控件的内容. 
			FileDelete, %addr%\%RowText% 	
			
			RowNumber := 0    ; 这样使得首次循环从列表的顶部开始搜索.
			preNum = 0 ;切换标题前的标题行号
			preText = "" ;切换标题前的标题 
			RowText =  ;重置当前行内容
			LV_Modify(1, "Select")
			LV_Modify(1, "Focus")
			ToolTip ,删除成功 
			 
			SetTimer, RemoveToolTip, 1000  
		}else{
			MsgBox,0,,请选择行   
			return  
		}		
	return    			
return	
	
; 保存小卡片
#s::  
	;如果窗口已经打开则选中
	IfWinExist, 新增卡片
	{
		WinActivate  ; 自动使用上面找到的窗口.   
		return
	}
	
	; 示例: 要求输入姓名的简单输入框: 
	Gui, Add:Add, Text,, 卡片名称:
	Gui, Add:Add, Text,, 卡片内容:
	Gui, Add:Add, Edit,  w700 vTitle ym  ; ym 选项开始一个新的控件列.
	Gui, Add:Add, Edit,r20 w700 vContent
	Gui, Add:Add, Button, default,Commit ; ButtonOK(如果存在)会在此按钮被按下时运行.
	
	Gui, Add:+Resize  ; 让用户可以调整窗口的大小.
	; 文件路径
	addr=D:\card
	
	Gui, Add:Show,, 新增卡片 
	return  ; 自动运行段结束. 在用户进行操作前脚本会一直保持空闲状态.
   
	AddGuiClose:
	AddGuiEscape: 	
		Gui Add:Destroy  ; 销毁关于对话框. 
	return	
	
	AddButtonCommit:  
		GuiControlGet, Title  ; 获取编辑控件的内容. 
		if ("" = Title)  
		{
			MsgBox,0,,标题必须输入  %Title% 
			return 		
		}
		else{
			GuiControlGet, Content  ; 获取编辑控件的内容.
			FileAppend, %Content%  `n,  %addr%\%Title%.txt 
			Gui, Add:Submit  ; 保存用户的输入到每个控件的关联变量中
			Gui Add:Destroy  ; 销毁关于对话框.
			return 					
		}  	 
	return


		
return	
  


	 
	
