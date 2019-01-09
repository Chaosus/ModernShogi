extends Node

#----------------------------------------------------------------#
# Константы
#----------------------------------------------------------------#

# Плоскость высоты доски
const SURFACE_H = 0.14

# Включить отладочные сообщения в консоль
const ENABLE_DEBUG_MSG = false

const SHOGI_PIECE_SIZE_Y = 0.14

#----------------------------------------------------------------#
# Перечисления
#----------------------------------------------------------------#

enum MarkMode {
	SELECT,
	ENEMY_SELECT,
	MOVE,
	ENEMY_MOVE,
	HOOK_MOVE,
	LAST_MOVE
	ENEMY_HOOK_MOVE,
	PROTECTION,
	ENEMY_PROTECTION
}

enum AvatarType {
	BLANK_SIMPLE,
	BLANK_MAN,
	BLANK_WOMAN,
	SYMBOL_YINYAN,
	DRAGON,
	GIRL_1,
	GIRL_2
	GIRL_3
	GIRL_ELF
}

enum Countries {
	UNKNOWN,
	ALBANIA,
	ALGERIA,
	ANDORRA,
	ANTIGUA_AND_BARBUDA,
	ARGENTINA,
	ARMENIA,
	AUSTRALIA,
	AUSTRIA,
	AZERBAIJAN,
	BAHAMAS,
	BAHRAIN,
	BARBADOS,
	BELARUS,
	BELGIUM,
	BOLIVIA,
	BOSNIA_AND_HERZEGOVINA,
	BRAZIL,
	BRUNEI,
	BULGARIA,
	CANADA,
	CHILE,
	CHINA,
	COLOMBIA,
	COSTARICA,
	CROATIA,
	CUBA,
	CYPRUS,
	CZECH,
	DENMARK,
	DOMINICAN_REPUBLIC,
	ECUADOR,
	EGYPT,
	ESTONIA,
	FIJI,
	FINLAND,
	FRANCE,
	GEORGIA,
	GERMANY,
	GREECE,
	GRENADA,
	GUYANA,
	HUNGARY,
	ICELAND,
	INDIA,
	INDONESIA,
	IRELAND,
	ISRAEL,
	ITALY,
	JAMAICA,
	JAPAN,
	JORDAN,
	KZ,
	KENYA,
	KYRGYZSTAN,
	LATVIA,
	LIECHTENSTEIN,
	LITHUANIA,
	LUXEMBOURG,
	MACEDONIA,
	MALAYSIA,
	MALDIVES,
	MALTA,
	MEXICO,
	MICRONESIA,
	MOLDOVA,
	MONACO,
	MONTENEGRO,
	MOROCCO,
	NETHERLANDS,
	NEW_ZEALAND,
	NIGERIA,
	NORWAY,
	OMAN,
	PAKISTAN,
	PANAMA,
	PARAGUAY,
	PERU,
	PHILIPPINES,
	POLAND,
	PORTUGAL,
	QATAR,
	ROMANIA,
	RUSSIA,
	SAUDI_ARABIA,
	SENEGAL,
	SERBIA,
	SINGAPORE,
	SLOVAKIA,
	SLOVENIA,
	SOUTH_AFRICA,
	SOUTH_KOREA,
	SPAIN,
	SRI_LANKA,
	SURINAME,
	SWEDEN,
	SWITZERLAND,
	TAIWAN,
	THAILAND,
	TRINIDAD,
	TUNISIA,
	TURKEY,
	UKRAINE,
	UAE,
	UK,
	USA,
	URUGUAY,
	UZBEKISTAN,
	VENEZUELA,
	VIETNAM
}

#----------------------------------------------------------------#
# Классы
#----------------------------------------------------------------#

class Country:
	var name
	var texture

#func set_country(element):
#	Profiles.get_temp_profile().country = get_country_tag(element.name)
#	get_screen(UI.SCREEN_CREATE_PROFILE).update_country(element)