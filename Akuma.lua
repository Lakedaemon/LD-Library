-- To Do :
-- Implement (complete) Kurikaeshi support
-- Improve the Yomigana Table (-stuff, stuff.ending, verb->noun)
-- Fix Compound support
-- Implement number compound
-- Implement syllaby compounds
-- Implement Occidental mode
-- Improve Katakana <-> hiragana correspondance



function GetVal(Cell,Nil)
	if Cell == nil then 
		return Nil
	else
		return Cell['$']
	end
end

function GetTable(Cell,Nil)
	if Cell == nil then 
		return Nil
	else
		return Cell
	end
end

function Normalize(Table)
 	if Table['$'] ~= nil then
		return {Table}
	else 
		return Table
	end
end

-- import the LuaXML module
package.path="F:/TeX/Akuma/?.lua"
XML = require('XML')

-- 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--	%													%
--	%					Kanjidic Loading					%
--	%													%
--	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



texio.write_nl("term and log","Loading Kanjidict...")
Time = os.clock()
local Kanjidictfile = io.open( 'F:/TeX/Akuma/Kanjidic2.xml', 'rb' ):read( '*a' )
local Kanjidict = XML(Kanjidictfile)

texio.write("term and log"," done in " .. os.clock() - Time .. " seconds.")
texio.write_nl("term and log","Preprocessiong...")
Time = os.clock()
Info={}
for Index, Item in  ipairs(Kanjidict.kanjidic2.character) do
	local Kanji = {}
	Kanji.Number = Index
	Kanji.Bushu = GetTable(Item.radical,-1) 
	Kanji.Strokes = GetTable(Item.misc.stroke_count,-1) 
	Kanji.Grade = GetVal(Item.misc.grade,-1)
	Kanji.JLPT = GetVal(Item.misc.jlpt,-1)
	Kanji.Frequency = GetVal(Item.misc.freq,-1)
	Kanji.ReadingMeaning = GetTable(Item.reading_meaning,-1)
	Info[Item.literal['$']] = Kanji
end
Kanjidict = nil 
Kanjidictfile = nil 



-- 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--	%													%
--	%					Kanjidic Preprocessing				%
--	%													%
--	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





for Literal, Kanji in pairs(Info) do
	Kanji.On = {}
	Kanji.Kun = {}
	Kanji.Nanori = {}
	if Kanji.ReadingMeaning ~= -1 then
		if Kanji.ReadingMeaning.nanori ~= nil then 
			for Index, Table in ipairs(Normalize(Kanji.ReadingMeaning.nanori)) do
				Kanji.Nanori[Index] = Table['$']
			end
		end
		if Kanji.ReadingMeaning.rmgroup ~= nil then
			if Kanji.ReadingMeaning.rmgroup.reading ~= nil then	
				--beware of grouped meaning/reading with multi rmgroup
				On_Number = 0
				Kun_Number = 0
				for Index, Table in ipairs(Normalize(Kanji.ReadingMeaning.rmgroup.reading)) do
					if Table["@r_type"] == "ja_on" then
						On_Number = On_Number + 1
						Kanji.On[On_Number] = Table["$"]
					elseif Table["@r_type"] == "ja_kun" then
						Kun_Number = Kun_Number + 1
						Kanji.Kun[Kun_Number] = Table["$"]					
					end
				end
			end
		end
	end
	Info[Literal] = Kanji
end



function TableStart(Kana, Start)
	if Start == "N" and Yomigana_Start[Kana] ~= nil then
		return Yomigana_Start[Kana]
	else
		return {Kana}
	end
end

function TableEnd(Kana, End)
	if End == "Y" and Yomigana_End[Kana] ~= nil then
		return Yomigana_End[Kana]
	elseif End == "N" and Yomigana_Middle[Kana] ~= nil then
		return Yomigana_Middle[Kana]
	else
		return {Kana}
	end
end

Yomigana_Start = {
	["か"]={"か","が"}, ["き"]={"き","ぎ"},["く"]={"く","ぐ"}, ["け"]={"け","げ"}, ["こ"]={"こ","ご"}, 
	["さ"]={"さ","ざ"}, ["し"]={"し","じ"},["す"]={"す","ず"}, ["せ"]={"せ","ぜ"}, ["そ"]={"そ","ぞ"}, 
	["た"]={"た","だ"}, ["ち"]={"ち","ぢ","じ"}, ["つ"]={"つ","づ","ず"}, ["っ"]={"つ","づ","ず"}, ["て"]={"て","で"}, ["と"]={"と","ど"}, 
	["は"]={"は","ば","ぱ"}, ["ひ"]={"ひ","び","ぴ"}, ["ふ"]={"ふ","ぶ","ぷ"}, ["へ"]={"へ","べ","ぺ"}, ["ほ"]={"ほ","ぼ","ぽ"}, 
	["カ"]={"カ","ガ"}, ["キ"]={"キ","ギ"}, ["ク"]={"ク","グ"}, ["ケ"]={"ケ","ゲ"}, ["コ"]={"コ","ゴ"}, 
	["サ"]={"サ","ザ"}, ["シ"]={"シ","ジ"}, ["ス"]={"ス","ズ"}, ["セ"]={"セ","ゼ"}, ["ソ"]={"ソ","ゾ"}, 
	["タ"]={"タ","ダ"}, ["チ"]={"チ","ヂ","ゾ"}, ["ツ"]={"ツ","ヅ","ズ"}, ["ッ"]={"ツ","ヅ","ズ"}, ["テ"]={"テ","デ"}, ["ト"]={"ト","ド"}, 
	["ハ"]={"ハ","バ","パ"}, ["ヒ"]={"ヒ","ビ","ピ"}, ["フ"]={"フ","ブ","プ"}, ["ヘ"]={"ヘ","ベ","ペ"},["ホ"]={"ホ","ボ","ポ"}
}

Yomigana_Middle = {
	["つ"] = {"つ","っ"}, ["く"] = {"く","っ"}, ["っ"] = {"っ"}, ["ツ"] = {"ツ","ッ"}, ["ッ"] = {"ッ"}, ["ク"] = {"ク","ッ"}, 
	["き"] = {"き", "っ"}, ["ち"] = {"ち", "っ"}, ["キ"] = {"キ", "ッ"}, ["チ"] = {"チ", "ッ"}
}

Yomigana_End = {
	["っ"]={"つ"}, ["ッ"]={"ツ"}
}


function Preprocess(Start, Kana, End, Readings)
	if unicode.utf8.len(Kana) == 1 then 
		for Index, LetterA in ipairs(TableStart(Kana, Start)) do
			for Number, LetterC in ipairs(TableEnd(LetterA, End)) do
				Readings[LetterC] = 0 
			end
		end
	else
		for Index, LetterA in ipairs(TableStart(unicode.utf8.sub(Kana,1,1), Start)) do
			for Rank, LetterC in ipairs(TableEnd(unicode.utf8.sub(Kana,-1), End)) do
				Readings[LetterA .. unicode.utf8.sub(Kana,2,-2) .. LetterC] = 0
			end
		end
	end
	return Readings
end

function Hiraganize(Kana)
	local Code = unicode.utf8.byte(Kana)  
	if Code > 12448 and Code < 12552 then 
		return unicode.utf8.char(Code - 96)
	else
		return Kana
	end
end

function Build_Yomigana_Table(Start, Literal, End, Kanji)
	local Readings = {} 

	for Index, On in ipairs(Kanji.On) do
		On = unicode.utf8.gsub(On, "%-","")
		On = unicode.utf8.gsub(On, "(.)", Hiraganize)
		Readings = Preprocess(Start, On, End, Readings)
	end
	for Index, Kun in ipairs(Kanji.Kun) do
		Kun = unicode.utf8.gsub(Kun, "%-","")
		if unicode.utf8.match(Kun, ".") ~= nil then
			First = unicode.utf8.gsub(Kun, "(.*)%..*","%1")
			Second = unicode.utf8.gsub(Kun, ".*%.(.*)","%1")
			Readings = Preprocess(Start, First, End, Readings)
			Letter = unicode.utf8.sub(Second, -1)
			if Verbs[Letter] == nil then
				-- Noun or Adverb
				Kun = First .. Second
			elseif Letter ~= "る" or GodanRuVerbs[Literal .. Second .. "|" .. First .. Second] ~= nil then
				-- Godan verb 
				Kun = unicode.utf8.sub(First .. Second, 1, -2)	 .. Verbs[Letter]				
			elseif IrregularVerbs[Literal .. Second .. "|" .. First .. Second] ~= nil then
				-- Irregular verb 
				Kun = Verbs[unicode.utf8.sub(First .. Second, 1, 1)]				
			else
				-- Ichidan verb
				Kun = unicode.utf8.sub(First .. Second, 1, -2)			
			end
		end
		Readings = Preprocess(Start, Kun, End, Readings)
	end
	for Index, Nanori in ipairs(Kanji.Nanori) do
		Readings = Preprocess(Start, Nanori, End, Readings)
	end
	Yomigana_Table[Start .. Literal .. End] = Readings
--	tex.print("\\par " .. Start .. Literal .. End .. " : ")
--	for Index, Reading in ipairs(Yomigana_Table[Start .. Literal .. End]) do
--		tex.print(Reading .. "\\quad " )
--	end
end

Verbs = {
	["う"] = "い", ["く"] = "き", ["ぐ"] = "ぎ", ["す"]="し", ["つ"]="ち", ["る"] = "り", ["ぬ"] = "に", ["む"] = "み", ["ぶ"] = "び"
}
RuVerbs = {
	["き"] = 0, ["ぎ"] = 0, ["け"] = 0, ["げ"] = 0, ["し"] = 0, ["じ"] = 0, ["せ"] = 0, ["ぜ"] = 0, ["ち"] = 0, ["ぢ"] = 0, ["て"] = 0, ["で"] = 0, ["ひ"] = 0, ["び"] = 0, ["ぴ"] = 0, ["へ"] = 0, ["べ"] = 0, ["ぺ"] = 0, ["り"] = 0, ["れ"] = 0, ["い"] = 0, ["え"] = 0, ["み"] = 0, ["め"] = 0, ["に"] = 0, ["ね"] = 0
}
GodanRuVerbs={
	["帰る|かえる"] = 0, ["入る|はいる"] = 0, ["切る|きる"] = 0, ["知る|しる"] = 0, ["要る|いる"] = 0
}

IrregularVerbs={
	["為る|する"] = 0, ["来る|くる"] = 0
}

-- Let's build the Yomigana Table
Yomigana_Table= {}
for Literal, Kanji in pairs(Info) do
	Build_Yomigana_Table("Y", Literal, "Y", Kanji)
	Build_Yomigana_Table("Y", Literal, "N", Kanji)
	Build_Yomigana_Table("N", Literal, "Y", Kanji)
	Build_Yomigana_Table("N", Literal, "N", Kanji)
end

Yomigana_Table["YケY"] = {["ケ"]=0, ["け"]=0, ["げ"]=0, ["か"]=0, ["が"]=0}	
Yomigana_Table["NケY"] = {["ケ"]=0, ["け"]=0, ["か"]=0}	
Yomigana_Table["YケN"] = {["ケ"]=0, ["け"]=0, ["げ"]=0, ["か"]=0, ["が"]=0}	
Yomigana_Table["NケN"] = {["ケ"]=0, ["け"]=0, ["か"]=0}	
Yomigana_Table["Y〆Y"] = {["しめ"]=0, ["じめ"]=0}	
Yomigana_Table["N〆Y"] = {["しめ"]=0}	
Yomigana_Table["Y〆N"] = {["しめ"]=0, ["じめ"]=0}	
Yomigana_Table["N〆N"] = {["しめ"]=0}	

-- Later improve the Yomigana Table (-stuff, stuff.ending, verb->noun)

Tableau = {
	-- UPPERCASE A - Z
	["Ａ"] = {"Ａ","エー","えー","ええ","えい","エイ"}, ["Ｂ"] = {"Ｂ","ビー","びー","びい","び","ベー"}, ["Ｃ"] = {"Ｃ","シー","しー","しい"}, 
	["Ｄ"] = {"Ｄ","ディー","でぃー","でぃ"}, ["Ｅ"] = {"Ｅ","イー","えー","えい"}, ["Ｆ"]={"Ｆ","エフ","えふ"}, ["Ｇ"]={"Ｇ","ジー"}, 
	["Ｈ"] = {"Ｈ","エッチ","ハー","エイチ"}, ["Ｉ"] = {"Ｉ","アイ","あい"}, ["Ｊ"] = {"Ｊ","ジェー","ジェイ","じぇい"}, ["Ｋ"] = {"Ｋ","ケー","けい"}, 
	["Ｌ"] = {"Ｌ","エル","える"}, ["Ｍ"] = {"Ｍ","エム","えむ"}, ["Ｎ"] = {"Ｎ","エヌ","えぬ"}, ["Ｏ"] = {"Ｏ","オー"}, ["Ｐ"] = {"Ｐ","ピー","ぴー"}, 
	["Ｑ"] = {"Ｑ","キュー","きゅう","きゅぜ"}, ["Ｒ"] = {"Ｒ","アール","あーる"}, ["Ｓ"] = {"Ｓ","エス","えす"}, ["Ｔ"] = {"Ｔ","ティー","てぃー","テー"}, 
	["Ｕ"] = {"Ｕ","ユー"}, ["Ｖ"] = {"Ｖ","ブイ","ビー"}, ["Ｗ"] = {"Ｗ","ダブリュー"}, ["Ｘ"] = {"Ｘ","エックス"}, ["Ｙ"]={"Ｙ","わい"}, ["Ｚ"] = {"Ｚ"}, 
	--  lowercase a- z
	["ａ"] = {"ａ","エー","えー","ええ","えい","エイ"}, ["ｂ"] = {"ｂ","ビー","びい"}, ["ｃ"] = {"ｃ","シー","しい"}, ["ｄ"] = {"ｄ","ディー"}, ["ｅ"]={"ｅ","イー","えー","えい"}, ["ｆ"] = {"ｆ","エフ","えふ"}, ["ｇ"] = {"ｇ","ジー"}, ["ｈ"] = {"ｈ","エッチ","エイチ"}, ["ｉ"] = {"ｉ","アイ"}, ["ｊ"]={"ｊ"}, ["ｋ"]={"ｋ", "ケー","けい"}, ["ｌ"]={"ｌ","エル"}, 
	["ｍ"] = {"ｍ","エム"}, ["ｎ"] = {"ｎ","エヌ"}, ["ｏ"] = {"ｏ","オー"}, ["ｐ"] = {"ｐ","ピー","ペー"}, ["ｑ"] = {"ｑ","キュー"}, ["ｒ"] = {"ｒ","アール"}, 
	["ｓ"] = {"ｓ","エス"}, ["ｔ"] = {"ｔ","ティー"}, ["ｕ"] = {"ｕ","ユー"}, ["ｖ"] = {"ｖ","ブイ","ビー"}, ["ｗ"] = {"ｗ","ダブリュー"}, 
	["ｘ"] = {"ｘ","エックス"}, ["ｙ"] = {"ｙ"}, ["ｚ"] = {"ｚ"}, 
	-- Numbers 0-9
	["０"] = {"０"}, ["１"] = {"１", "いち", "いつ", "ひと"}, ["２"] = {"２", "に", "ふた"}, ["３"] = {"３", "さん"}, ["４"] = {"４","よん", "よっ", "し"}, 
	["５"] = {"５","ご","いつ"}, ["６"] = {"６","ろく", "む","むっ","むい"}, ["７"] = {"７","しち","なの","なな"}, ["８"] = {"８","はち", "や","やっ","よう"}, 
	["９"] = {"９","きゅう", "ここの","く"}, 
	-- Greek alphabet lowercase
	["α"] = {"アルファ"},  ["β"] =  {"ベータ"}, ["ε"] = {"エプシロン","イプシロン"}, ["ζ"] = {"ゼータ"}, ["η"] = {"エータ","イータ"}, 
	["θ"] = {"テータ","シータ"}, ["ι"] = {"イオタ"}, ["κ"] = {"カッパー","カッパ"}, ["λ"] = {"ラムダ"}, ["μ"] = {"ミュー"}, ["ν"] = {"ニュー"}, 
	["ξ"] = {"グザイ","クサイ","クシー"}, ["ο"] = {"オミクロン"}, ["π"] = {"パイ"}, ["ρ"] = {"ロー"}, ["σ"] = {"シグマ"},  ["τ"] = {"タウ"}, 
	["υ"] = {"ユプシロン", "ウプシロン"}, ["φ"] = {"フィー", "ファイ"}, ["χ"] = {"キー", "カイ"}, ["ψ"] = {"プシー", "プサイ"}, ["ω"] = {"オメガ"},  
	-- Greek alphabet UPPERCASE 
	["Α"] =  {"アルファ"}, ["Β"] = {"ベータ"}, ["Ε"] = {"イプシロン","エプシロン"}, ["Ζ"] = {"ゼータ"}, ["Η"] = {"イータ","エータ"}, 
	["Θ"] = {"テータ"}, ["Ι"] = {"イオタ"}, ["Κ"] = {"カッパ","カッパー"}, ["Λ"] = {"ラムダ"}, ["Μ"] = {"ミュー"}, ["Ν"] = {"ニュー"}, 
	["Ξ"] = {"クサイ","クシー","グザイ"},  ["Ο"] = {"オミクロン"}, ["Π"] = {"パイ"}, ["Ρ"] = {"ロー"}, ["Σ"] = {"シグマ"}, ["Τ"] = {"タウ"}, 
	["Υ"] = {"ウプシロン","ユプシロン"}, ["Φ"] = {"ファイ","フィー"}, ["Χ"] = {"キー"}, ["Ψ"] = {"プサイ","プシー"},  ["Ω"] = {"オメガ"},  
	-- Various Symbols
	["＋"] = {"プラス"}, ["○"] = {"まる"}, ["〇"] = {"まる"}, ["×"] = {"ばつ","ペケ"}, ["→"] = {"やじるし"}, ["←"] = {"やじるし"}, ["＠"] = {"アットマーク","ナルト"}, ["．"] = {"．"}, 
	["※"] = {"こめじるし"}, ["〒"] = {"ゆうびんきごう"}
}


for Literal, Readings in pairs(Tableau) do
	local Table={}
	for Index, Reading in ipairs(Readings) do
		Table = Preprocess("Y", Reading, "Y", Table)
	end
	Yomigana_Table["Y" .. Literal .. "Y"] = Table
	local Table={}
	for Index, Reading in ipairs(Readings) do
		Table = Preprocess("N", Reading, "Y", Table)
	end
	Yomigana_Table["N" .. Literal .. "Y"] = Table
	local Table={}
	for Index, Reading in ipairs(Readings) do
		Table = Preprocess("Y", Reading, "N", Table)
	end
	Yomigana_Table["Y" .. Literal .. "N"] = Table
	local Table={}
	for Index, Reading in ipairs(Readings) do
	Table = Preprocess("N", Reading, "N", Table)
	end
	Yomigana_Table["N" .. Literal .. "N"] = Table
end

texio.write("term and log","done in " .. os.clock() - Time .. " seconds.")





-- 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--	%													%
--	%				Yomigana Compute Functions	V3			%
--	%													%
--	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LD_Yomigana_Compounds = {
	["今日|きょう"] = 0, ["眼鏡|めがね"] = 0, ["部屋|へや"] = 0, ["何時|いつ"] = 0, ["如何|どう"] = 0, ["悪戯|いたずら"] = 0, ["為替|かわせ"] = 0, ["相撲|すもう"] = 0, ["大和|やまと"] = 0, ["相撲|ずもう"] = 0, ["土産|みやげ"] = 0, ["海苔|のり"] = 0, ["蝦夷|えぞ"] = 0, ["海豚|いるか"] = 0, ["自棄|やけ"] = 0, ["団扇|うちわ"] = 0, ["雲雀|ひばり"] = 0, ["飛蝗|ばった"] = 0, ["酸漿|ほおずき"] = 0, ["似非|えせ"] = 0, ["上手|うま"] = 0, ["山羊|やぎ"] = 0, ["山葵|わさび"] = 0, ["時雨|しぐれ"] = 0, ["従兄弟|いとこ"] = 0, ["従姉妹|いとこ"] = 0, ["小豆|あずき"] = 0, ["梅雨|つゆ"] = 0, ["博士|はかせ"] = 0, ["烏賊|いか"] = 0, ["何方|どちら"] = 0, ["何方|どっち"] = 0, ["何故|なぜ"] = 0, ["昨日|きのう"] = 0, ["一昨日|おととい"] = 0, ["可愛|かわい"] = 0, ["気質|かたぎ"] = 0, ["蜻蛉|とんぼ"] = 0, ["土産|みやげ"] = 0
}

function AtStart(Number)
	if Number == 1 then
		return "Y"
	else 
		return "N"
	end
end

function AtEnd(Number)
	if Number ==  Tango_End then
		return "Y"
	else 
		return "N"
	end
end

function Compute_Yomigana(Tang, Yom) 
	-- initializes things and starts the recursive process
	Tango = Tang
	Yomi = Yom
	Tango_End = unicode.utf8.len(Tango)
	Yomi_End = unicode.utf8.len(Yomi)	
	return Dispatch_Process(0, 1, Tango_End, 1, Yomi_End) 
end


function Dispatch_Process(Mode, T_Start, T_End, Y_Start, Y_End)
	--tex.print("\\par " .. unicode.utf8.sub(Tango, T_Start, T_End) .." + " .. Sub(Yomi, Y_Start,Y_End) .. " = " .. Mode)
	-- The Lakedaemonian Recursive Function implementing a kind of Dichotomy.  
	if T_End == T_Start then
		--
		--	Kanji
		--
		return One_Kanji(Mode, T_Start, Y_Start, Y_End)
	elseif T_End == T_Start + 1 and unicode.utf8.sub(Tango, T_End, T_End) == "々" then
		--
		-- 	Kanji 々
		--
		return Kanji_Kurikaeshi(Mode, T_Start, Y_Start, Y_End)
	elseif LD_Yomigana_Compounds[unicode.utf8.sub(Tango,T_Start,T_End) .. "|" .. Sub(Yomi,Y_Start,Y_End)] ~= nil then
		--
		-- 	Regular Compound
		--
		return unicode.utf8.rep("|", T_End-T_Start) .. Sub(Yomi, Y_Start, Y_End) .. "|", 0, 0
	else
		--
		-- 	Dichotomy : Split Tango string and Yomi string
		--
		return Dichotomy(Mode, T_Start, T_End, Y_Start, Y_End)
	end
end

function Sub(String, a, b)
	if b < a or b == 0 then 
		return ""
	elseif a == 0 then
		return unicode.utf8.sub(String, 1, b)	
	else
		return unicode.utf8.sub(String, a, b)	
	end
end

function One_Kanji(Mode, T_Rank, Y_Start, Y_End)
	--
	-- One Kanji case. 
	-- This case does the Grunt Work (it compares with the lectures) and happens a lot. 	
	--
	local Kanji = unicode.utf8.sub(Tango, T_Rank, T_Rank)
	local Kana = Sub(Yomi, Y_Start, Y_End)
	local Test = Yomigana_Table[AtStart(T_Rank) .. Kanji .. AtEnd(T_Rank)] 
	if Test ~= nil and Test[Kana] == nil then 
		--
		-- Quirk case
		--
		return Quirk_Case(Mode, Kana, 1) 
	elseif Test ~= nil or Kanji == Kana then
		--
		-- Valid case
		--
		return Kana .. "|", 0, 0
	else
		--
		-- Special Case
		--
		--Furigana, Quirks, Mode = Quirk_Case(Mode, Kana, 15) 
		return Special_Case(Mode, Kanji, Kana, Y_End-Y_Start)
	end
end		
			
		
function Quirk_Case(Mode, Kana, Increment)
	if Mode < 2  and Kana ~="" then
		return "*" .. Kana .. "|", Increment, 2
	elseif Mode < 2 then
		return "*|", Increment, 1
	elseif Kana == "" then
		-- Forbidden case
		return "*|", 666, 1
	else
		-- Forbidden case
		return "*" .. Kana .. "|", 666, 2
	end
end
	
function Special_Case(Mode, Kanji, Kana, Delta)
	if  Delta == 0 then
		local Kanji_Number = unicode.utf8.byte(Kanji)
		local Kana_Number = unicode.utf8.byte(Kana)
		if Kana_Number == Kanji_Number + 96 and Kanji_Number > 12352 and Kanji_Number < 12436 then 
			--
			-- Valid case (hiragana with katakana reading)
			--
			return Kana .. "|", 0, 0
		elseif  Kanji_Number == Kana_Number + 96 and Kanji_Number > 12448 and Kanji_Number < 12532  then
			--
			-- Valid case (katakana with hiragana reading)
			--
			return Kana .. "|", 0, 0
		else
			--
			-- Quirk case
			--
			return Quirk_Case(Mode, Kana, 10) 
		end	
	else 
		--
		-- Quirk case
		--
		return Quirk_Case(Mode, Kana, 10) 
	end	
end

function Dichotomy(Mode, T_Start, T_End, Y_Start, Y_End)	
	local Saved_Furigana = "*|*|" -- these should have initial values
	Saved_Mode  = 0 -- these should have initial values
	local Saved_Quirks = 6667 
	--	we could do the loop with a for statement but then we would have to break it
	local Crab_Step = 0 
	local T_Mean = math.floor((T_Start + T_End) / 2)
	local Y_Mean = math.floor((Y_Start + Y_End) / 2)
	for Step = 0, Y_End - Y_Start + 1 do
		local FuriganaA, FuriganaB, QuirksA, QuirksB, Temp_Mode
		-- Crab walk
		FuriganaA, QuirksA, Temp_Mode = Dispatch_Process(Mode, T_Start, T_Mean, Y_Start, Y_Mean - Crab_Step) 
		-- Test if it is usefull to continue
		if QuirksA < Saved_Quirks then 
			-- we go for the first solution. Now bring the second Daemon to the fray
			FuriganaB, QuirksB, Temp_Mode = Dispatch_Process(Temp_Mode, T_Mean + 1, T_End, Y_Mean + 1 - Crab_Step, Y_End) 
			if QuirksA + QuirksB < Saved_Quirks then 
				-- We have a winner here, save it's data
				Saved_Furigana = FuriganaA .. FuriganaB
				Saved_Mode = Temp_Mode
				Saved_Quirks = QuirksA + QuirksB
				if Saved_Quirks == 0 then
					break
				end
			end
		end
		--
		if Crab_Step > 0 then
			Crab_Step = - Crab_Step
		else
			Crab_Step = 1 - Crab_Step
		end
	end		
	return Saved_Furigana, Saved_Quirks, Saved_Mode
end 

--[[
Yomigana, Quirks = 	Compute_Yomigana("ＮＡＰＳ","ナプス")
tex.print("\\par\\noindent ")
tex.print(Yomigana..Quirks)

Yomigana, Quirks = 	Compute_Yomigana("荷為替手形","にがわせてがた")
tex.print("\\par\\noindent ")
tex.print(Yomigana..Quirks)
Yomigana, Quirks = 	Compute_Yomigana("荷為替手","にがわせてがた")
tex.print("\\par\\noindent ")
tex.print(Yomigana..Quirks)

]]--

function Kanji_Kurikaeshi(Mode, T_Start, Y_Start, Y_End)
	local Quirks_Saved = 100
	local Furi_Saved = "*|*" .. Sub(Yomi, Y_Start, Y_End)  .. "|"
	local Kanji = unicode.utf8.sub(Tango, T_Start, T_Start)
	if Yomigana_Table["N" .. Kanji .. "N"] ~= nil then
		TestA = Kurikaeshi_Test_Deux
		TestB = Kurikaeshi_Test_Trois
	else	
		-- Unknown kanji, tests if kana are the same
		TestA = Kurikaeshi_Test
		TestB = function() return false end			
	end
	local Crab_Step = 0 
	local Y_Mean = math.floor((Y_Start + Y_End) / 2)
	for Step = 0, Y_End - Y_Start + 1 do
		local Quirks, FuriA, FuriB
		local KanaA = Sub(Yomi, Y_Start, Y_Mean - Crab_Step)
		local KanaB = Sub(Yomi, Y_Mean - Crab_Step + 1, Y_End)
		if TestA(Y_Start, Y_Mean - Crab_Step, Y_End, Kanji, T_Start) == true then
			Quirks = 0
			FuriB = KanaB .. "|"
		else
			Quirks = 50
			FuriB = "*" .. KanaB .. "|"
		end
		if Quirks < Quirks_Saved then
			if TestB(Kanji, T_Start, Kana_A) == false then
				Quirks = Quirks + 1 
				FuriA = "*" .. KanaA .. "|"
			else
				FuriA = KanaA .. "|"
			end
		end
		if Quirks > 50 and KanaA ~= "" then
			Quirks = 666
		end
		if Quirks < Quirks_Saved then
			Quirks_Saved = Quirks
			Furi_Saved = FuriA .. FuriB
		end
		if Quirks_Saved == 0 then
			break
		end
		--
		if Crab_Step > 0 then
			Crab_Step = - Crab_Step
		else
			Crab_Step = 1 - Crab_Step
		end
	end
	if Quirks_Saved > 51 then
		Mode = 2
	else  -- Fix here
		Mode = 0
	end
	return Furi_Saved, Quirks_Saved, Mode
end

function KuriTestA(Y_A, Y_B)
	local LetterA = unicode.utf8.sub(Yomi, Y_A, Y_A)
	local LetterB = unicode.utf8.sub(Yomi, Y_B, Y_B)
	if Y_A == 1 then 
		Table = Kurikaeshi_B_Start["Y" .. LetterA]
	else
		Table = Kurikaeshi_B_Start["N" .. LetterA]	
	end
	if Table == nil and LetterA ~= LetterB then
		return false
	elseif Table ~= nil and Table[LetterB] == nil then
		return false
	else 
		return true
	end
end

function KuriTestB(Y_A, Y_B)
	local LetterA = unicode.utf8.sub(Yomi, Y_A, Y_A)
	local LetterB = unicode.utf8.sub(Yomi, Y_B, Y_B)
	if Y_B == Yomi_End then 
		Table = Kurikaeshi_B_End[letterA]
	else
		Table = Kurikaeshi_B_Middle[LetterA]
	end
	-- Optimize this. 
	if Table == nil and LetterA ~= LetterB then
		return false
	elseif Table ~= nil and Table[LetterB] == nil then 
		return false
	else 
		return true
	end
end

function Kurikaeshi_Test_Deux(Y_Start, Y_Middle, Y_End, Kanji, T_Pos)
	Table = Yomigana_Table["N" .. Kanji .. AtEnd(T_Pos)] 
	if Table[Sub(Yomi, Y_Middle + 1, Y_End)] ~= nil then 
	 	return true
	else 
		return Kurikaeshi_Test(Y_Start, Y_Middle, Y_End)
	end
end

function Kurikaeshi_Test(Y_Start, Y_Middle, Y_End) 
	if  Y_Middle - Y_Start ~= Y_End - Y_Middle - 1 then
		return false
	elseif Y_Middle == Y_Start and KuriTestA(Y_Start, Y_Middle + 1) == false then -- fix this
		return false
	elseif Y_Middle == Y_Start  then
		return true
	elseif Y_Middle > Y_Start + 1 and unicode.utf8.sub(Yomi, Y_Start + 1, Y_Middle - 1) ~= unicode.utf8.sub(Yomi, Y_Middle + 2, Y_End - 1) then
		return false
	elseif KuriTestA(Y_Start, Y_Middle + 1) == false  then
		return false
	elseif KuriTestB(Y_Middle, Y_End) == false then 
		return false
	else
		return true
	end
end

function Kurikaeshi_Test_Trois(Kanji, T_Pos, Kana)
	Table = Yomigana_Table[AtStart(T_Pos) .. Kanji .. "N"]
	if Table[Kana] ~= nil then
		return true
	else
		return false
	end
end

-- 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--	%													%
--	%				Yomigana Compute Functions				%
--	%													%
--	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Kurikaeshi_B_Start = {}
for Key, Table in pairs(Yomigana_Start) do
	local Tabledeux={}
	for Index, Kana in ipairs(Table) do
		Tabledeux[Kana] = 0
	end
	for Index, Kana in ipairs(Table) do
		-- き -> き et ぎ   
		-- ぎ -> き et ぎ  
		Kurikaeshi_B_Start["N".. Kana] = Tabledeux
		if Yomigana_Start[Kana] == nil then
			-- ぎ -> ぎ  
			Kurikaeshi_B_Start["Y".. Kana] = {Kana}
		else
			-- き -> き et ぎ 
			Kurikaeshi_B_Start["Y".. Kana] = Tabledeux
		end		
	end
end


Kurikaeshi_B_Middle = {
	["つ"] = {"つ","っ"},["っ"] = {"っ","つ"}, ["く"] = {"く","っ"},  ["ツ"] = {"ツ","ッ"}, ["ッ"] = {"ッ","ツ"}, ["ク"] = {"ク","ッ"}, 
	["き"] = {"き", "っ"}, ["ち"] = {"ち", "っ"}, ["キ"] = {"キ", "ッ"}, ["チ"] = {"チ", "ッ"}
}

Kurikaeshi_B_End = {
	["っ"]={"つ"}, ["ッ"]={"ツ"}
}





LD_Yomigana_Compounds = {
	["今日|きょう"] = 0, ["眼鏡|めがね"] = 0, ["部屋|へや"] = 0, ["何時|いつ"] = 0, ["如何|どう"] = 0, ["悪戯|いたずら"] = 0, ["為替|かわせ"] = 0, ["相撲|すもう"] = 0, ["大和|やまと"] = 0, ["相撲|ずもう"] = 0, ["土産|みやげ"] = 0, ["海苔|のり"] = 0, ["蝦夷|えぞ"] = 0, ["海豚|いるか"] = 0, ["自棄|やけ"] = 0, ["団扇|うちわ"] = 0, ["雲雀|ひばり"] = 0, ["飛蝗|ばった"] = 0, ["酸漿|ほおずき"] = 0, ["似非|えせ"] = 0, ["上手|うま"] = 0, ["山羊|やぎ"] = 0, ["山葵|わさび"] = 0, ["時雨|しぐれ"] = 0, ["従兄弟|いとこ"] = 0, ["従姉妹|いとこ"] = 0, ["小豆|あずき"] = 0, ["梅雨|つゆ"] = 0, ["博士|はかせ"] = 0, ["烏賊|いか"] = 0, ["何方|どちら"] = 0, ["何方|どっち"] = 0, ["何故|なぜ"] = 0, ["昨日|きのう"] = 0, ["一昨日|おととい"] = 0, ["可愛|かわい"] = 0, ["気質|かたぎ"] = 0, ["蜻蛉|とんぼ"] = 0, ["土産|みやげ"] = 0
}

	
	



-- 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--	%													%
--	%					JMdic Preprocessing					%
--	%													%
--	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

texio.write_nl("term and log","Loading JMdict...")
Time = os.clock()
local JMdictfile = io.open( 'F:/TeX/Akuma/JMdict.xml', 'rb' ):read( '*a' )
JMdictfile = unicode.utf8.gsub(JMdictfile,"<!%-%-.-%-%->","") -- strip the comments
local JMdictXML = XML(JMdictfile)


texio.write("term and log","done in " .. os.clock() - Time .. " seconds.")
texio.write_nl("term and log","Preprocessing JMdict...")
Time = os.clock()

Dict={}
local Count = 0
for Index, Item in pairs(JMdictXML.JMdict.entry) do
	local Entry = {}
	Entry.Id = GetVal(Item.ent_seq,-1)
	Entry.KanjiReadings = GetTable(Item.k_ele,-1) 
	Entry.KanaReadings = GetTable(Item.r_ele,-1) 
	Entry.Sense = GetTable(Item.sense,-1) 
	Count = Count + 1
	Dict[Count] = Entry
end
JMdictXML= nil  
JMdictfile = nil 

texio.write("term and log","done in " .. os.clock() - Time .. "seconds.")


-- 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--	%													%
--	%					Computing Yomigana					%
--	%													%
--	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


--[[
Yomigana, Quirks = 	LD_Yomigana_Compute("外国為替銀行","がいこくかわせぎんこう")
tex.print("\\par\\noindent 外 \\quad")
for Kana, Zero in pairs(Yomigana_Table["Y" .. "外" .. "N"]) do 
	tex.print(Kana.." \\quad")
end
tex.print("\\par\\noindent 応 \\quad")
for Kana, Zero in pairs(Yomigana_Table["N" .. "応" .. "N"]) do 
	tex.print(Kana.." \\quad")
end
tex.print("\\par\\noindent 為 \\quad")
for Kana, Zero in pairs(Yomigana_Table["N" .. "為" .. "N"]) do 
	tex.print(Kana.." \\quad")
end
tex.print("\\par\\noindent 替 \\quad")
for Kana, Zero in pairs(Yomigana_Table["N" .. "替" .. "N"]) do 
	tex.print(Kana.." \\quad")
end
tex.print("\\par\\noindent 銀 \\quad")
for Kana, Zero in pairs(Yomigana_Table["N" .. "銀" .. "N"]) do 
	tex.print(Kana.." \\quad")
end
tex.print("\\par\\noindent 行 \\quad")
for Kana, Zero in pairs(Yomigana_Table["N" .. "行" .. "Y"]) do 
	tex.print(Kana.." \\quad")
end
tex.print("\\par\\noindent ")
tex.print(Yomigana..Quirks)
]]--

texio.write_nl("term and log","Computing Yomigana...")
Time = os.clock()



function Yomigana_Stats(Tango,Furigana)
	local Compound_Mode = 0
	local Compound = ""
	for Furi in string.gmatch(Furigana, "([^|]*)|") do 
		if Furi == "" then
			Compound = Compound .. unicode.utf8.sub(Tango, 1, 1)
			Compound_Mode = 1 
		elseif Furi == "*" then
			Compound = Compound .. unicode.utf8.sub(Tango, 1, 1)
			Compound_Mode = 2 
		elseif  unicode.utf8.sub(Furi, 1, 1) == "*" then 
			Update_Stats(Compound .. unicode.utf8.sub(Tango, 1, 1), unicode.utf8.sub(Furi, 2, -1), "*")
			Compound_Mode = 0
			Compound = ""
		else
			if Compound_Mode == 2 then
				Update_Stats(Compound, "", "*")
				Update_Stats(unicode.utf8.sub(Tango, 1, 1), Furi, "")
			else
				Update_Stats(Compound .. unicode.utf8.sub(Tango, 1, 1), Furi, "")
			end
			Compound_Mode = 0
			Compound = ""
		end
		if unicode.utf8.len(Tango) > 1 then
			Tango = unicode.utf8.sub(Tango, 2, -1)
		else
			Tango = ""
		end
       end
end

Stats={}

function Update_Stats(Compound, Furigana, Mode)
	if Stats[Compound] == nil then
		Table = {} 
	else
		Table = Stats[Compound]
	end
	if Table[Furigana] == nil then
		Table[Furigana] = {["Number"] = 1, ["Mode"] = Mode}
	else
		Table[Furigana].Number = Table[Furigana].Number + 1
	end
	Stats[Compound] = Table
end

function Restriction(ReRestr, Kanji)
	local Test = false
	if ReRestr == nil then
		Test = true
	else
	 	for Index, String  in ipairs(Normalize(ReRestr)) do
			if String == Kanji then
				Test = true
			end
		end
	end
	return Test
end

function Normalizer(Table)
 	if Table[1] == nil then
		return {Table}
	else 
		return Table
	end
end

Total_Pairs = 0
Total_QuirkPairs = 0
Total_Quirks = 0
Record = {}
Count = 0
for Index, Entry in ipairs(Dict) do
	if Entry.KanjiReadings ~= -1 and Entry.KanaReadings ~= -1 then
		for Number, KElement in ipairs(Normalizer(Entry.KanjiReadings)) do
			if KElement.keb ~= nil then 
				for Rank, RElement in ipairs(Normalizer(Entry.KanaReadings)) do
					if RElement.reb ~= nil and RElement.re_nokanji == nil and Restriction(RElement.re_restr,KElement.keb['$']) == true  then
--						Yomigana, Quirks = 	LD_Yomigana_Compute(KElement.keb['$'], RElement.reb['$'])
						Yomigana, Quirks = 	Compute_Yomigana(KElement.keb['$'], RElement.reb['$'])						
						Count = Count +1 
						Record[Count] = {KElement.keb['$'], Yomigana, Quirks}
						Yomigana_Stats(KElement.keb['$'], Yomigana)
						Total_Pairs = Total_Pairs +1
						if Quirks >0 then
							Total_QuirkPairs = Total_QuirkPairs +1
							Total_Quirks = Total_Quirks + Quirks
						end
--						tex.print("\\par ".. Kanji_Reading['$'] .. " - ".. Kana_Reading['$'] .. " : "  .. Yomigana .. " (" .. Quirks .. ")" )
					end
				end
			end
		end
	end
end



texio.write("term and log"," done in " .. os.clock() - Time  .. " seconds")

tex.print("Total : "..Total_Pairs  .." Quirks : " .. Total_QuirkPairs.. " Ratio : " .. math.floor(10000*Total_QuirkPairs/Total_Pairs)/100 .. "\\% Total Quirks : " .. Total_Quirks .."\\bigskip")


-- 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
--	%													%
--	%					Sorting the data						%
--	%													%
--	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


texio.write_nl("term and log","Computing Stats...")
Time = os.clock()

StatsSorted={}
Count = 0
for Compound, Table in pairs(Stats) do
	Count = Count +1
	local Quirked = 0
	for Furigana, Liste in pairs(Table) do
		if Liste.Mode == "*" then 
			Quirked = Quirked + Liste.Number 
		end
	end
	StatsSorted[Count] = {["Compound"] = Compound, ["Array"] = Table, ["Quirked"] = Quirked}
end

table.sort(StatsSorted, function(a,b) if a.Quirked > b.Quirked then return true else return false end end )

texio.write("term and log"," done in " .. os.clock() - Time  .. " seconds")
texio.write_nl("term and log","Displaying Stats...")
Time = os.clock()

for Index, Table in ipairs(StatsSorted) do
	tex.print("\\medskip\\noindent\\LD@Font@Kana ".. Table.Compound .." ".. Table.Quirked .."\\qquad\\LD@Font@Kana@Tiny ")
	local FuriSorted = {}
	local Count = 0
	for Furigana, Liste in pairs(Table.Array) do
		Count = Count + 1 
		if Liste.Mode == "" then 
			FuriSorted[Count] = {["String"]=Furigana, ["Number"] = 300 + Liste.Number , ["Mode"] = Liste.Mode}
		else
			FuriSorted[Count] = {["String"]=Furigana, ["Number"] = Liste.Number , ["Mode"] = Liste.Mode}
		end
	end
	table.sort(FuriSorted, function(a,b) if a.Number > b.Number then return true else return false end end )
	for Index, Furigana in ipairs(FuriSorted) do
		if Furigana.Mode == "" then
			tex.print(Furigana.Number - 300 .. Furigana.String .. " " .. Furigana.Mode .. "\\quad ")			
		else
			tex.print(Furigana.Number .. Furigana.String .. " " .. Furigana.Mode .. "\\quad ")
		end
	end
end

texio.write("term and log"," done in " .. os.clock() - Time  .. " seconds")

table.sort(Record, function(a,b) if a[3] < b[3] then return true else return false end end )
Count = 0 
for Index, Yomigana in ipairs(Record) do
	Count = Count + 1 
	if Count > 10 then
		tex.print("\\smallskip\\noindent ")
		Count = 0
	end
	tex.print(Yomigana[1] .." + " .. Yomigana[2] .. " = ".. Yomigana[3] .. " \\quad")
end


--[[
for Compound, Table in pairs(Stats) do
	tex.print("\\par\\noindent ".. Compound .."\\qquad ")
	for Furigana, Liste in pairs(Table) do
		tex.print(Liste.Number .. Furigana .. " " .. Liste.Mode .. "\\quad ")
	end
end
]]--


--[[
		Yomigana_Table["ゐYY"]=",ゐ,い,"	
		Yomigana_Table["ゐNY"]=",ゐ,い,"	
		Yomigana_Table["ゐYN"]=",ゐ,い,"	
		Yomigana_Table["ゐNN"]=",ゐ,い,"	
		Yomigana_Table["ゑYY"]=",ゑ,え,"	
		Yomigana_Table["ゑNY"]=",ゑ,え,"	
		Yomigana_Table["ゑYN"]=",ゑ,え,"	
		Yomigana_Table["ゑNN"]=",ゑ,え,"	
		Yomigana_Table["をYY"]=",を,お,"	
		Yomigana_Table["をNY"]=",を,お,"	
		Yomigana_Table["をYN"]=",を,お,"	
		Yomigana_Table["をNN"]=",を,お,"	
		Yomigana_Table["はYY"]=",は,ば,ぱ,わ,"	
		Yomigana_Table["はNY"]=",は,わ,"	
		Yomigana_Table["はYN"]=",は,ば,ぱ,わ,"	
		Yomigana_Table["はNN"]=",は,わ,"	
		Yomigana_Table["ほYY"]=",ほ,ぼ,ぽ,お,"	
		Yomigana_Table["ほNY"]=",ほ,お,"	
		Yomigana_Table["ほYN"]=",ほ,ぼ,ぽ,お,"	
		Yomigana_Table["ほNN"]=",ほ,お,"	
		Yomigana_Table["へYY"]=",へ,べ,ぺ,え,"	
		Yomigana_Table["へNY"]=",へ,え,"	
		Yomigana_Table["へYN"]=",へ,べ,ぺ,え,"	
		Yomigana_Table["へNN"]=",へ,え,"	
		Yomigana_Table["ひYY"]=",ひ,び,ぴ,い,"	
		Yomigana_Table["ひNY"]=",ひ,い,"	
		Yomigana_Table["ひYN"]=",ひ,び,ぴ,い,"	
		Yomigana_Table["ひNN"]=",ひ,い,"	
		Yomigana_Table["ふYY"]=",ふ,ぶ,ぷ,う,"	
		Yomigana_Table["ふNY"]=",ふ,ぶ,ぷ,う,"	
		Yomigana_Table["ふYN"]=",ふ,ぶ,ぷ,う,"	
		Yomigana_Table["ふNN"]=",ふ,ぶ,ぷ,う,"	
		LD_Yomigana_KurikaeshiSymbols = "々ヽヾゝゞ"]]--

