extends "res://scripts/UIScreen.gd"

class Country:
	var tag
	var name
	var texture
	func _init(tag, name, texture):
		self.tag = tag
		self.name = name
		self.texture = load("res://ui/flags/" + texture)
	
class CountryCategory:
	var name
	var countries = []
	func _init(name):
		self.name = name
	func append_country(country):
		countries.append(country)
		return country
	
var categories = []

func create_countries():
	var cat_app = CountryCategory.new("App")
	cat_app.append_country(Country.new(Globals.Countries.UNKNOWN, "CY_UNKNOWN", "unknown.jpg"))
	var usa = Country.new(Globals.Countries.USA, "CY_USA", "usa.jpg")
	cat_app.append_country(usa)
	var russia = cat_app.append_country(Country.new(Globals.Countries.RUSSIA, "CY_RUSSIA", "russia.jpg"))
	categories.append(cat_app)
	
	var cat_cis = CountryCategory.new("CIS")
	cat_cis.append_country(russia)
	var belarus = cat_cis.append_country(Country.new(Globals.Countries.BELARUS, "CY_BELARUS", "belarus.jpg"))
	var kz = cat_cis.append_country(Country.new(Globals.Countries.KZ, "CY_KZ", "kz.jpg"))
	var ukraine = Country.new(Globals.Countries.UKRAINE, "CY_UKRAINE", "ukraine.jpg")
	cat_cis.append_country(ukraine)
	categories.append(cat_cis)
	
	var cat_asia = CountryCategory.new("ASIA")
	var japan = cat_asia.append_country(Country.new(Globals.Countries.JAPAN, "CY_JAPAN", "japan.jpg"))
	var china = cat_asia.append_country(Country.new(Globals.Countries.CHINA, "CY_CHINA", "china.jpg")) # 1
	var south_korea = cat_asia.append_country(Country.new(Globals.Countries.SOUTH_KOREA, "CY_SOUTH_KOREA", "south_korea.jpg")) # 20
	categories.append(cat_asia)
	
	var cat_a = CountryCategory.new("A")
	cat_a.append_country(Country.new(Globals.Countries.ALBANIA, "CY_ALBANIA", "albania.jpg"))
	cat_a.append_country(Country.new(Globals.Countries.ALGERIA, "CY_ALGERIA", "algeria.jpg"))
	cat_a.append_country(Country.new(Globals.Countries.ANDORRA, "CY_ANDORRA", "andorra.jpg"))
	cat_a.append_country(Country.new(Globals.Countries.ANTIGUA_AND_BARBUDA, "CY_AAB", "antigua_and_barbuda.jpg"))
	cat_a.append_country(Country.new(Globals.Countries.ARGENTINA, "CY_ARGENTINA", "argentina.jpg")) # 25
	cat_a.append_country(Country.new(Globals.Countries.ARMENIA, "CY_ARMENIA", "armenia.jpg"))
	cat_a.append_country(Country.new(Globals.Countries.AUSTRALIA, "CY_AUSTRALIA", "australia.jpg")) # 33
	cat_a.append_country(Country.new(Globals.Countries.AUSTRIA, "CY_AUSTRIA", "austria.jpg"))
	cat_a.append_country(Country.new(Globals.Countries.AZERBAIJAN, "CY_AZERBAIJAN", "azerbaijan.jpg"))
	categories.append(cat_a)
	
	var cat_b = CountryCategory.new("B")
	cat_b.append_country(Country.new(Globals.Countries.BAHAMAS, "CY_BAHAMAS", "bahamas.jpg"))
	cat_b.append_country(Country.new(Globals.Countries.BAHRAIN, "CY_BAHRAIN", "bahrain.jpg"))
	cat_b.append_country(Country.new(Globals.Countries.BARBADOS, "CY_BARBADOS", "barbados.jpg"))
	cat_b.append_country(belarus)
	cat_b.append_country(Country.new(Globals.Countries.BELGIUM, "CY_BELGIUM", "belgium.jpg"))
	cat_b.append_country(Country.new(Globals.Countries.BOLIVIA, "CY_BOLIVIA", "bolivia.jpg"))
	cat_b.append_country(Country.new(Globals.Countries.BOSNIA_AND_HERZEGOVINA, "CY_BAH", "bosnia_and_herzegovina.jpg"))
	cat_b.append_country(Country.new(Globals.Countries.BRAZIL, "CY_BRAZIL", "brazil.jpg")) # 4
	cat_b.append_country(Country.new(Globals.Countries.BRUNEI, "CY_BRUNEI", "brunei.jpg"))
	cat_b.append_country(Country.new(Globals.Countries.BULGARIA, "CY_BULGARIA", "bulgaria.jpg"))
	categories.append(cat_b)
	
	var cat_c = CountryCategory.new("C")
	cat_c.append_country(Country.new(Globals.Countries.CANADA, "CY_CANADA", "canada.jpg")) # 24
	cat_c.append_country(Country.new(Globals.Countries.CHILE, "CY_CHILE", "chile.jpg"))
	cat_c.append_country(china)
	cat_c.append_country(Country.new(Globals.Countries.COLOMBIA, "CY_COLOMBIA", "colombia.jpg")) # 27
	cat_c.append_country(Country.new(Globals.Countries.COSTARICA, "CY_COSTARICA", "costarica.png"))
	cat_c.append_country(Country.new(Globals.Countries.CROATIA, "CY_CROATIA", "croatia.jpg"))
	cat_c.append_country(Country.new(Globals.Countries.CUBA, "CY_CUBA", "cuba.jpg"))
	cat_c.append_country(Country.new(Globals.Countries.CYPRUS, "CY_CYPRUS", "cyprus.jpg"))
	cat_c.append_country(Country.new(Globals.Countries.CZECH, "CY_CZECH", "czech.jpg"))
	categories.append(cat_c)
	
	var cat_d = CountryCategory.new("D")
	cat_d.append_country(Country.new(Globals.Countries.DENMARK, "CY_DENMARK", "denmark.jpg"))
	cat_d.append_country(Country.new(Globals.Countries.DOMINICAN_REPUBLIC, "CY_DOMINICAN_REPUBLIC", "dominican_republic.jpg"))
	categories.append(cat_d)
	
	var cat_e = CountryCategory.new("E")
	cat_e.append_country(Country.new(Globals.Countries.ECUADOR, "CY_ECUADOR", "ecuador.jpg"))
	cat_e.append_country(Country.new(Globals.Countries.EGYPT, "CY_EGYPT", "egypt.jpg")) # 23
	cat_e.append_country(Country.new(Globals.Countries.ESTONIA, "CY_ESTONIA", "estonia.jpg"))
	categories.append(cat_e)
	
	var cat_f = CountryCategory.new("F")
	cat_f.append_country(Country.new(Globals.Countries.FIJI, "CY_FIJI", "fiji.jpg"))
	cat_f.append_country(Country.new(Globals.Countries.FINLAND, "CY_FINLAND", "finland.jpg"))
	cat_f.append_country(Country.new(Globals.Countries.FRANCE, "CY_FRANCE", "france.jpg")) # 17
	categories.append(cat_f)
	
	var cat_g = CountryCategory.new("G")
	cat_g.append_country(Country.new(Globals.Countries.GEORGIA, "CY_GEORGIA", "georgia.jpg"))
	cat_g.append_country(Country.new(Globals.Countries.GERMANY, "CY_GERMANY", "germany.jpg")) # 11
	cat_g.append_country(Country.new(Globals.Countries.GREECE, "CY_GREECE", "greece.jpg"))
	cat_g.append_country(Country.new(Globals.Countries.GRENADA, "CY_GRENADA", "grenada.jpg"))
	cat_g.append_country(Country.new(Globals.Countries.GUYANA, "CY_GUYANA", "guyana.jpg"))
	categories.append(cat_g)
	
	var cat_h = CountryCategory.new("H")
	cat_h.append_country(Country.new(Globals.Countries.HUNGARY, "CY_HUNGARY", "hungary.jpg"))
	categories.append(cat_h)
	
	var cat_i = CountryCategory.new("I")
	cat_i.append_country(Country.new(Globals.Countries.ICELAND, "CY_ICELAND", "iceland.jpg"))
	cat_i.append_country(Country.new(Globals.Countries.INDIA, "CY_INDIA", "india.jpg")) # 2
	cat_i.append_country(Country.new(Globals.Countries.INDONESIA, "CY_INDONESIA", "indonesia.jpg")) # 5
	cat_i.append_country(Country.new(Globals.Countries.IRELAND, "CY_IRELAND", "ireland.jpg"))
	cat_i.append_country(Country.new(Globals.Countries.ISRAEL, "CY_ISRAEL", "israel.jpg"))
	cat_i.append_country(Country.new(Globals.Countries.ITALY, "CY_ITALY", "italy.jpg")) # 19
	categories.append(cat_i)
	
	var cat_j = CountryCategory.new("J")
	cat_j.append_country(Country.new(Globals.Countries.JAMAICA, "CY_JAMAICA", "jamaica.jpg"))
	cat_j.append_country(japan) # 6
	cat_j.append_country(Country.new(Globals.Countries.JORDAN, "CY_JORDAN", "jordan.jpg"))
	categories.append(cat_j)
	
	var cat_k = CountryCategory.new("K")
	cat_k.append_country(kz)
	cat_k.append_country(Country.new(Globals.Countries.KENYA, "CY_KENYA", "kenya.jpg")) # 32
	cat_k.append_country(south_korea)
	cat_k.append_country(Country.new(Globals.Countries.KYRGYZSTAN, "CY_KYRGYZSTAN", "kyrgyzstan.jpg"))
	categories.append(cat_k)
	
	var cat_l = CountryCategory.new("L")
	cat_l.append_country(Country.new(Globals.Countries.LATVIA, "CY_LATVIA", "latvia.jpg"))
	cat_l.append_country(Country.new(Globals.Countries.LIECHTENSTEIN, "CY_LIECHTENSTEIN", "liechtenstein.jpg"))
	cat_l.append_country(Country.new(Globals.Countries.LITHUANIA, "CY_LITHUANIA", "lithuania.jpg"))
	cat_l.append_country(Country.new(Globals.Countries.LUXEMBOURG, "CY_LUXEMBOURG", "luxembourg.jpg"))
	categories.append(cat_l)
	
	var cat_m = CountryCategory.new("M")
	cat_m.append_country(Country.new(Globals.Countries.MACEDONIA, "CY_MACEDONIA", "macedonia.jpg"))
	cat_m.append_country(Country.new(Globals.Countries.MALAYSIA, "CY_MALAYSIA", "malaysia.jpg")) # 29
	cat_m.append_country(Country.new(Globals.Countries.MALDIVES, "CY_MALDIVES", "maldives.jpg"))
	cat_m.append_country(Country.new(Globals.Countries.MALTA, "CY_MALTA", "malta.jpg"))
	cat_m.append_country(Country.new(Globals.Countries.MEXICO, "CY_MEXICO", "mexico.jpg")) # 9
	cat_m.append_country(Country.new(Globals.Countries.MICRONESIA, "CY_MICRONESIA", "micronesia.jpg"))
	cat_m.append_country(Country.new(Globals.Countries.MOLDOVA, "CY_MOLDOVA", "moldova.jpg"))
	cat_m.append_country(Country.new(Globals.Countries.MONACO, "CY_MONACO", "monaco.jpg"))
	cat_m.append_country(Country.new(Globals.Countries.MONTENEGRO, "CY_MONTENEGRO", "montenegro.jpg"))
	cat_m.append_country(Country.new(Globals.Countries.MOROCCO, "CY_MOROCCO", "morocco.jpg")) # 34
	categories.append(cat_m)
	
	var cat_n = CountryCategory.new("N")
	cat_n.append_country(Country.new(Globals.Countries.NETHERLANDS, "CY_NETHERLANDS", "netherlands.jpg"))
	cat_n.append_country(Country.new(Globals.Countries.NEW_ZEALAND, "CY_NEW_ZEALAND", "new_zealand.jpg"))
	cat_n.append_country(Country.new(Globals.Countries.NIGERIA, "CY_NIGERIA", "nigeria.jpg"))
	cat_n.append_country(Country.new(Globals.Countries.NORWAY, "CY_NORWAY", "norway.jpg"))
	categories.append(cat_n)
	
	var cat_o = CountryCategory.new("O")
	cat_o.append_country(Country.new(Globals.Countries.OMAN, "CY_OMAN", "oman.jpg"))
	categories.append(cat_o)
	
	var cat_p = CountryCategory.new("P")
	cat_p.append_country(Country.new(Globals.Countries.PANAMA, "CY_PANAMA", "panama.jpg"))
	cat_p.append_country(Country.new(Globals.Countries.PARAGUAY, "CY_PARAGUAY", "paraguay.jpg"))
	cat_p.append_country(Country.new(Globals.Countries.PERU, "CY_PERU", "peru.jpg"))
	cat_p.append_country(Country.new(Globals.Countries.PHILIPPINES, "CY_PHILIPPINES", "philippines.jpg")) # 14
	cat_p.append_country(Country.new(Globals.Countries.POLAND, "CY_POLAND", "poland.jpg")) # 28
	cat_p.append_country(Country.new(Globals.Countries.PORTUGAL, "CY_PORTUGAL", "portugal.jpg"))
	categories.append(cat_p)
	
	var cat_q = CountryCategory.new("Q")
	cat_q.append_country(Country.new(Globals.Countries.QATAR, "CY_QATAR", "qatar.jpg"))
	categories.append(cat_q)
	
	var cat_r = CountryCategory.new("R")
	cat_r.append_country(Country.new(Globals.Countries.ROMANIA, "CY_ROMANIA", "romania.jpg"))
	cat_r.append_country(russia) # 7
	categories.append(cat_r)
	
	var cat_s = CountryCategory.new("S")
	cat_s.append_country(Country.new(Globals.Countries.SAUDI_ARABIA, "CY_SAUDI_ARABIA", "saudi_arabia.jpg")) # 30
	cat_s.append_country(Country.new(Globals.Countries.SENEGAL, "CY_SENEGAL", "senegal.jpg")) # 79
	cat_s.append_country(Country.new(Globals.Countries.SERBIA, "CY_SERBIA", "serbia.jpg")) # 62
	cat_s.append_country(Country.new(Globals.Countries.SINGAPORE, "CY_SINGAPORE", "singapore.jpg")) # 71
	cat_s.append_country(Country.new(Globals.Countries.SLOVAKIA, "CY_SLOVAKIA", "slovakia.jpg")) # 70
	cat_s.append_country(Country.new(Globals.Countries.SLOVENIA, "CY_SLOVENIA", "slovenia.jpg")) # 93
	cat_s.append_country(Country.new(Globals.Countries.SOUTH_AFRICA, "CY_SOUTH_AFRICA", "south_africa.jpg")) # 26
	cat_s.append_country(south_korea)
	cat_s.append_country(Country.new(Globals.Countries.SPAIN, "CY_SPAIN", "spain.jpg")) # 21
	cat_s.append_country(Country.new(Globals.Countries.SRI_LANKA, "CY_SRI_LANKA", "sri_lanka.jpg")) # 60
	cat_s.append_country(Country.new(Globals.Countries.SURINAME, "CY_SURINAME", "suriname.jpg")) # 142
	cat_s.append_country(Country.new(Globals.Countries.SWEDEN, "CY_SWEDEN", "sweden.jpg")) # 45
	cat_s.append_country(Country.new(Globals.Countries.SWITZERLAND, "CY_SWITZERLAND", "switzerland.jpg")) # 52
	categories.append(cat_s)
	
	var cat_t = CountryCategory.new("T")
	cat_t.append_country(Country.new(Globals.Countries.TAIWAN, "CY_TAIWAN", "taiwan.jpg")) # 36
	cat_t.append_country(Country.new(Globals.Countries.THAILAND, "CY_THAILAND", "thailand.jpg")) # 15
	cat_t.append_country(Country.new(Globals.Countries.TRINIDAD, "CY_TRINIDAD", "trinidad.jpg")) # 117
	cat_t.append_country(Country.new(Globals.Countries.TUNISIA, "CY_TUNISIA", "tunisia.jpg")) # 65
	cat_t.append_country(Country.new(Globals.Countries.TURKEY, "CY_TURKEY", "turkey.jpg")) # 18
	categories.append(cat_t)
	
	var cat_u = CountryCategory.new("U")
	cat_u.append_country(ukraine) # 31
	cat_u.append_country(Country.new(Globals.Countries.UAE, "CY_UAE", "uae.jpg")) # 47
	cat_u.append_country(Country.new(Globals.Countries.UK, "CY_UK", "uk.jpg")) # 13
	cat_u.append_country(usa) # 3
	cat_u.append_country(Country.new(Globals.Countries.URUGUAY, "CY_URUGUAY", "uruguay.jpg")) # 91
	cat_u.append_country(Country.new(Globals.Countries.UZBEKISTAN, "CY_UZBEKISTAN", "uzbekistan.jpg")) # 38
	categories.append(cat_u)
	
	var cat_v = CountryCategory.new("V")
	cat_v.append_country(Country.new(Globals.Countries.VENEZUELA, "CY_VENEZUELA", "venezuela.jpg")) # 35
	cat_v.append_country(Country.new(Globals.Countries.VIETNAM, "CY_VIETNAM", "vietnam.jpg")) # 12
	categories.append(cat_v)
	
	for item in categories:
		add_category_elements(item)
		
	var cbox = get_node("PanelEN/VBox/ScrollContainer/VBox/Grid/CountryContainer/")
	var panel = get_node("PanelEN/VBox/ScrollContainer/VBox/Grid/CountryContainer/ReferenceRect").duplicate()
	cbox.add_child(panel)

func add_category_elements(category):
	
	var label = Label.new()
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.text = category.name
	label.size_flags_horizontal = Label.SIZE_EXPAND_FILL and Label.SIZE_EXPAND
	label.size_flags_vertical = Label.SIZE_SHRINK_CENTER
	label.rect_min_size = Vector2(300, 192)
	
	var box = get_node("PanelEN/VBox/ScrollContainer/VBox/Grid/TagContainer/")	
	box.add_child(label)
	
	var cbox = get_node("PanelEN/VBox/ScrollContainer/VBox/Grid/CountryContainer/")
	var hbox = HBoxContainer.new()
	hbox.theme = preload("res://themes/hv_big_division.tres")
	cbox.add_child(hbox)
	
	for item in category.countries:
		UI.add_country(item.tag, item.name, item.texture)
		var vbox = VBoxContainer.new()
		vbox.theme = preload("res://themes/hv_medium_division.tres")
		var btn = TextureButton.new()
		btn.name = item.name
		btn.rect_min_size = Vector2(225, 150)
		btn.expand = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		btn.texture_normal = item.texture
		btn.connect("pressed", self, "set_country", [ btn, item.tag ] )
		vbox.add_child(btn)
		var desc = Label.new()
		desc.text = item.name
		desc.align = Label.ALIGN_CENTER
		desc.valign = Label.VALIGN_CENTER
		UI.add_unnamed_small_element(desc)
		vbox.add_child(desc)
		hbox.add_child(vbox)

func _ready():
	self.title = "TITLE_SELECT_COUNTRY"
	
func set_country(button, tag):
	if previous_screen != null:
		UI.country_tag = tag
		Profiles.get_current_profile().country = tag
		UI.country_button.texture_normal = UI.country_list[tag].texture
		UI.country_button.tooltip = UI.get_country_name(tag)
		if UI.country_button2:
			UI.country_button2.texture_normal = UI.country_list[tag].texture
			UI.country_button2.tooltip = UI.get_country_name(tag)
		if UI.country_label:
			UI.country_label.text = UI.country_list[tag].tag
	go_back_if_possible()