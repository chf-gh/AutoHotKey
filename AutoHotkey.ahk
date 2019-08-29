
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
		WinActivate   ; 自动使用上面找到的窗口.   
		return
	}
	Gui, Show:+Resize  ; 让用户可以调整窗口的大小. 
	; 创建含名称和大小两列的 ListView:
	Gui, Show:Add, ListView, AltSubmit w200  x0 y0 gFileListView vFileListView   SortDesc c222222 Grid ,  Name|create_date
	 
	Gui, Show:Add, Edit, w700 x+0 r34 vItemContent , 未选择行 
	
	Gui, Show:Font, s10 cBlack , Verdana  ; 如果需要, 使用这样的一行给窗口设置新的默认字体.
    GuiControl, Show:Font, ItemContent  ; 让上面的字体设置对控件生效.
    GuiControl, Show:Font, FileListView  ; 让上面的字体设置对控件生效.
	 
	; 创建作为上下文菜单的弹出菜单:
	Menu, FileContextMenu, Add, Delete, ContextDeleteFile 
	 
	; 文件路径
	addr=D:\auto-card
	
	Gui, Show:Default  ;设置当前窗口为默认操作窗口,后续的方法如：LV_Add都是对当前窗口的list操作
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
	Gui, Show:Show, ,所有卡片  ;显示窗口并将窗口名称设置为：“所有卡片”
	return
	  
	ShowGuiClose:
	ShowGuiEscape: 	 
		preNum = 0 ;切换标题前的标题行号
		preText = "" ;切换标题前的标题 
		if("" != RowText){  
			GuiControlGet, ItemContent,Show:  ; 获取编辑控件的内容. 
			FileDelete, %addr%\%RowText% 			
			FileAppend,%ItemContent%,  %addr%\%RowText%   
			Gui, Show:Submit, NoHide  ; 保存用户的输入到每个控件的关联变量中   
		}
		Gui Show:Destroy  ; 销毁关于对话框.  
	return	
	ShowGuiContextMenu:  ; 运行此标签来响应右键点击或按下 Appskey.
		if (A_GuiControl != "FileListView")  ; 仅在 ListView 中点击时才显示菜单.
			return
		; 在提供的坐标处显示菜单, A_GuiX 和 A_GuiY. 应该使用这些
		; 因为即使用户按下 Appskey 它们也会提供正确的坐标:
		Menu, FileContextMenu, Show, %A_GuiX%, %A_GuiY%
	return
	ShowGuiSize:  ; 扩大或缩小 ListView 来响应用户对窗口大小的改变.
		if (A_EventInfo = 1)  ; 窗口被最小化了.  无需进行操作.
			return
		; 否则, 窗口的大小被调整过或被最大化了. 调整 ListView 的大小来适应.
		GuiControl, Show:Move, FileListView, % "W" . (200) . " H" . (A_GuiHeight )
		GuiControl, Show:Move, ItemContent, % "W" . (A_GuiWidth - 200) . " H" . (A_GuiHeight )
		
	return	
	FileListView:  
		
		if (preNum != 0 and "" != preText)
		{   
			LV_GetText(preText, preNum, 1) ; 获取首个字段的文本.
 
			GuiControlGet, ItemContent,Show:   ; 获取编辑控件的内容. 
			FileDelete, %addr%\%preText% 		;删除后再添加实现自动保存效果	
			FileAppend, %ItemContent%,  %addr%\%preText%   
			Gui, Show:Submit, NoHide  ; 保存用户的输入到每个控件的关联变量中   
		  
		}  
		FocusedRowNumber := LV_GetNext( , "F")  ; 查找焦点行. 
		if not FocusedRowNumber  ; 没有焦点行.
			return
		LV_GetText(RowText, FocusedRowNumber, 1) ; 获取首个字段的文本.
		
		FileRead, FileContents, %addr%\%RowText%
		GuiControl,Show:,ItemContent,%FileContents%  
		GuiControl,Show:Focus,ItemContent
		preNum = %FocusedRowNumber%; 
		
		
		  
	return 
 
	;tooltip函数
	RemoveToolTip:
	SetTimer, RemoveToolTip, Off
	ToolTip
	return
	
	ContextDeleteFile:  ; 删除文件  
	   
		 if( RowText != "" ){ 
			Gui, Show:Default  ;设置当前窗口为默认操作窗口,后续的方法如：LV_Add都是对当前窗口的list操作
			MsgBox,292,,确定删除: %RowText% 这个卡片吗？    
			IfMsgBox No
				return 
			; 删除列表中的行
			RowNumber := 0    ; 这样使得首次循环从列表的顶部开始搜索.
			Loop
			{
				RowNumber := LV_GetNext(RowNumber - 1)  ; 在前一次找到的位置后继续搜索.
				if not RowNumber  ; 上面返回零, 所以选择的行已经都找到了.
					break
				LV_Delete(  RowNumber) 
			}
			; 删除文件
			GuiControlGet, ItemContent,Show:  ; 获取编辑控件的内容. 
			FileDelete, %addr%\%RowText% 	
			 	
			preNum := 0 ;切换标题前的标题行号	 
			preText := "" ;切换标题前的标题 
			 
			LV_Modify(1, "Select")
			LV_Modify(1, "Focus")
			;重新显示焦点行数据
			LV_GetText(RowText, 1, 1) ; 获取首个字段的文本.
			
			if("" != RowText){  
				FileRead, FileContents, %addr%\%RowText%
				GuiControl,Show:,ItemContent,%FileContents%  
				GuiControl,Show:Focus,ItemContent
			}
			 
			
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
	
	Gui, Add:-Resize    ; 让用户可以调整窗口的大小.
	; 示例: 要求输入姓名的简单输入框: 
	Gui, Add:Add, Text,, 卡片名称:
	Gui, Add:Add, Text,, 卡片内容:
	Gui, Add:Add, Edit,  w700 vTitle ym  ; ym 选项开始一个新的控件列.
	Gui, Add:Add, Edit,r20 w700 vContent
	Gui, Add:Add, Button, default,Commit ; ButtonOK(如果存在)会在此按钮被按下时运行.
	
	Gui, Add:Font, s10 cBlack , Verdana  ; 如果需要, 使用这样的一行给窗口设置新的默认字体.
    GuiControl, Add:Font, Title  ; 让上面的字体设置对控件生效.
    GuiControl, Add:Font, Content  ; 让上面的字体设置对控件生效. 
	
	; 文件路径
	addr=D:\auto-card
	
	Gui, Add:Show,, 新增卡片  ;显示窗口并将窗口名称设置为：“新增卡片”
	return  ; 自动运行段结束. 在用户进行操作前脚本会一直保持空闲状态.
   
	AddGuiClose:
	AddGuiEscape: 	
		Gui Add:Destroy  ; 销毁关于对话框. 
	return	
	

	AddButtonCommit:  
		GuiControlGet, Title,Add:  ; 获取编辑控件的内容. 
		if ("" = Title)  
		{
			MsgBox,0,,标题必须输入  %Title% 
			return 		
		}
		else{
			GuiControlGet, Content,Add: ; 获取编辑控件的内容.
			FileAppend, %Content%  `n,  %addr%\%Title%.txt 
			Gui, Add:Submit  ; 保存用户的输入到每个控件的关联变量中
			Gui Add:Destroy  ; 销毁关于对话框.
			return 					
		}  	 
	return
 
return	

; 快捷方式
#q::  
	;如果窗口已经打开则选中
	IfWinExist, 快捷方式
	{
		WinActivate  ; 自动使用上面找到的窗口.   
		return
	}
	 ; 允许用户最大化窗口或拖动来改变窗口的大小:
	Gui ShortCat:+Resize +Theme 
 

	; 通过 Gui Add 创建 ListView 及其列:
	Gui, ShortCat:Add, ListView,x0 y0   r30 w800 vMyListView gMyListView, Name|In Folder|Size (KB)|Type 
	GuiControl, ShortCat:+Icon, MyListView    ; 切换到图标视图
	Gui, ShortCat:Default  ;设置当前窗口为默认操作窗口,后续的方法如：LV_Add都是对当前窗口的list操作
	LV_ModifyCol(3, "Integer")  ; 为了排序, 表示 Size 列中的内容是整数.

	; 创建图像列表, 这样 ListView 才可以显示图标: 
	ImageListID  := IL_Create(10, 10, true)  ; 大图标列表 
	LV_SetImageList(ImageListID)

	; 创建作为上下文菜单的弹出菜单:
	Menu, MyContextMenu, Add, Open, ContextOpenFile
	Menu, MyContextMenu, Add, Properties, ContextProperties
	Menu, MyContextMenu, Add, Clear from ListView, ContextClearRows
	Menu, MyContextMenu, Default, Open  ; 让 "Open" 粗体显示表示双击时会执行相同的操作.

	 
	sfi := 600  ;图标容量
	Folder=D:\auto-shortcat  ;设置快捷方式的位置
	
	; 获取所选择文件夹中的文件名列表并添加到 ListView:
	GuiControl, ShortCat:-Redraw, MyListView  ; 在加载时禁用重绘来提升性能.
	Loop %Folder%\*.*
	{
		FileName := A_LoopFileFullPath  ; 必须保存到可写的变量中供后面使用.

		; 建立唯一的扩展 ID 以避免变量名中的非法字符,
		; 例如破折号. 这种使用唯一 ID 的方法也会执行地更好,
		; 因为在数组中查找项目不需要进行搜索循环.
		SplitPath, FileName,,, FileExt  ; 获取文件扩展名.
		if FileExt in EXE,ICO,ANI,CUR
		{
			ExtID := FileExt  ; 特殊 ID 作为占位符.
			IconNumber := 0  ; 进行标记这样每种类型就含有唯一的图标.
		}
		else  ; 其他的扩展名/文件类型, 计算它们的唯一 ID.
		{
			ExtID := 0  ; 进行初始化来处理比其他更短的扩展名.
			Loop 7     ; 限制扩展名为 7 个字符, 这样之后计算的结果才能存放到 64 位值.
			{
				ExtChar := SubStr(FileExt, A_Index, 1)
				if not ExtChar  ; 没有更多字符了.
					break
				; 把每个字符与不同的位位置进行运算来得到唯一 ID:
				ExtID := ExtID | (Asc(ExtChar) << (8 * (A_Index - 1)))
			}
			; 检查此文件扩展名的图标是否已经在图像列表中. 如果是,
			; 可以避免多次调用并极大提高性能,
			; 尤其对于包含数以百计文件的文件夹而言:
			IconNumber := IconArray%ExtID%
		}
		if not IconNumber  ; 此扩展名还没有相应的图标, 所以进行加载.
		{
			; 获取与此文件扩展名关联的高质量小图标:
			if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "Str", FileName
				, "UInt", 0, "Ptr", &sfi, "UInt", sfi_size, "UInt", 0x100)  ; 0x101 为 SHGFI_ICON+SHGFI_SMALLICON 0x100 将文件的HICON类型的图标
				IconNumber := 9999999  ; 把它设置到范围外来显示空图标.
			else ; 成功加载图标.
			{
				; 从结构中提取 hIcon 成员:
				hIcon := NumGet(sfi, 0)
				; 直接添加 HICON 到 大图标列表. 
				IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID, "Int", -1, "Ptr", hIcon) + 1
				; 现在已经把它复制到图像列表, 所以应销毁原来的:
				DllCall("DestroyIcon", "Ptr", hIcon) 
			}
		}
 
		; 在 ListView 中创建新行并把它和上面的图标编号进行关联:
		LV_Add("Icon" . IconNumber, A_LoopFileName, A_LoopFileDir, A_LoopFileSizeKB, FileExt)
	}
	GuiControl, ShortCat:+Redraw, MyListView  ; 重新启用重绘 (上面把它禁用了).
	
	LV_ModifyCol()  ; 根据内容自动调整每列的大小.
	LV_ModifyCol(3, 60) ; 把 Size 列加宽一些以便显示出它的标题.
	
 
	; 显示窗口并返回. 当用户执行预期的动作时
	; 操作系统会通知脚本:
	Gui, ShortCat:Show ,,快捷方式 ;显示窗口并将窗口名称设置为：“快捷方式”
	return

	ShortCatGuiClose:
	ShortCatGuiEscape: 	
		Gui ShortCat:Destroy  ; 销毁关于对话框. 
	return	
 
	MyListView:
	if (A_GuiEvent = "DoubleClick")  ; 脚本还可以检查许多其他的可能值.
	{
		LV_GetText(FileName, A_EventInfo, 1) ; 从首个字段中获取文本.
		LV_GetText(FileDir, A_EventInfo, 2)  ; 从第二个字段中获取文本.
		Run %FileDir%\%FileName%, , UseErrorLevel
		if ErrorLevel
			MsgBox Could not open "%FileDir%\%FileName%".
	}
	return

	ShortCatGuiContextMenu:  ; 运行此标签来响应右键点击或按下 Appskey.
		if (A_GuiControl != "MyListView")  ; 仅在 ListView 中点击时才显示菜单.
			return
		; 在提供的坐标处显示菜单, A_GuiX 和 A_GuiY. 应该使用这些
		; 因为即使用户按下 Appskey 它们也会提供正确的坐标:
		Menu, MyContextMenu, Show, %A_GuiX%, %A_GuiY%
	return

	ContextOpenFile:  ; 用户在上下文菜单中选择了 "Open".
	ContextProperties:  ; 用户在上下文菜单中选择了 "Properties".
		Gui, ShortCat:Default  ;设置当前窗口为默认操作窗口,后续的方法如：LV_Add都是对当前窗口的list操作
		; 为了简化, 仅对焦点行进行操作而不是所有选择的行:
		FocusedRowNumber := LV_GetNext(0, "F")  ; 查找焦点行.
		if not FocusedRowNumber  ; 没有焦点行.
			return
		LV_GetText(FileName, FocusedRowNumber, 1) ; 获取首个字段的文本.
		LV_GetText(FileDir, FocusedRowNumber, 2)  ; 获取第二个字段的文本.
		if InStr(A_ThisMenuItem, "Open")  ; 用户在上下文菜单中选择了 "Open".
			Run %FileDir%\%FileName%,, UseErrorLevel
		else  ; 用户在上下文菜单中选择了 "Properties".
			Run Properties "%FileDir%\%FileName%",, UseErrorLevel
		if ErrorLevel
			MsgBox Could not perform requested action on "%FileDir%\%FileName%".
	return

	ContextClearRows:  ; 用户在上下文菜单中选择了 "Clear".
	 
		Gui, ShortCat:Default  ;设置当前窗口为默认操作窗口,后续的方法如：LV_Add都是对当前窗口的list操作
		RowNumber := 0  ; 这会使得首次循环从顶部开始搜索.
		Loop
		{
			; 由于删除了一行使得此行下面的所有行的行号都减小了,
			; 所以把行号减 1, 这样搜索里包含的行号才会与之前找到的行号相一致
			; (以防选择了相邻行):
			RowNumber := LV_GetNext(RowNumber - 1)
			if not RowNumber  ; 上面返回零, 所以没有更多选择的行了.
				break
				
			LV_GetText(FileName, RowNumber, 1) ; 获取首个字段的文本.
			FileDelete, %Folder%\%FileName% 	
			 	 
			LV_Delete(RowNumber)  ; 从 ListView 中删除行.
			MsgBox 删除成功 	
		}
	return

	ShortCatGuiSize:  ; 扩大或缩小 ListView 来响应用户对窗口大小的改变.
		if (A_EventInfo = 1)  ; 窗口被最小化了.  无需进行操作.
			return
		; 否则, 窗口的大小被调整过或被最大化了. 调整 ListView 的大小来适应.
		GuiControl, ShortCat:Move, MyListView, % "W" . (A_GuiWidth - 0) . " H" . (A_GuiHeight - 0)
		 
	return
	ShortCatGuiDropFiles:  ; 对拖放提供支持.
		Loop, Parse, A_GuiEvent, `n
		{ 
			;只移动快捷方式,  A_GuiEvent:当前的文件名称
			SplitPath, A_GuiEvent,,, FileExt  ; 获取文件扩展名.
			if("lnk" != FileExt){
				MsgBox 已忽略非快捷方式的文件 
			}else{ 
				; 不移动重复图标  %A_Index% 多个文件时的下标  %A_LoopField%：文件位置 
				FileMove, %A_LoopField%, %Folder% ;移动文件到快捷方式文件夹下
			}
		}
	return
 
return
  
