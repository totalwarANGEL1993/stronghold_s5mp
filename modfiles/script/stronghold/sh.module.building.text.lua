--- 
--- Texts for the buildings
--- 

Stronghold.Province.Text.UI = {
    Reputation = {de = "Beliebtheit", en = "Reputation"},
    Honor = {de = "Ehre", en = "Honor"},

    Require = {
        de = " @cr @color:244,184,0 benötigt: @color:255,255,255 ",
        en = " @cr @color:244,184,0 requires: @color:255,255,255 ",
    },
    Effect  = {
        de = " @cr @color:244,184,0 bewirkt: @color:255,255,255 ",
        en = " @cr @color:244,184,0 achives: @color:255,255,255 ",
    },
}

Stronghold.Building.Text.Msg = {
    MeasureNotReady = {
        de = "Hochwohlgeboren, Ihr könnt noch keine neue Maßnahme anordnen!",
        en = "Your Highness, you cannot yet order a new measure!",
    },
    MeasureRandomTax = {
        de = "Ihr habt %d Taler erhalten!",
        en = "The levy tax produced %d Gold!"
    },
}

Stronghold.Building.Text.SelectLord = {
    de = "@color:180,180,180 Adligen wählen @color:255,255,255 "..
         "@cr Wählt euren Adligen aus. Jeder Adlige verfügt über "..
         "starke Fähigkeiten. Ohne einen Adligen könnt ihr keine "..
         "Ehre erhalten.",
    en = "@color:180,180,180 Choose Noble @color:255,255,255 "..
         " Choose your Noble. Each Noble has different strengths "..
         " and weaknesses. Without a Noble you can not gain honor.",
}

Stronghold.Building.Text.SubMenu = {
    Treasury = {
        de = "{grey}Schatzkammer{white}{cr}Hier könnt Ihr Leibeigene "..
             "kaufen, Euren Adligen wählen, den Alarm ausrufen und später "..
             "sogar die Steuern einstellen.",
        en = "{grey}Treasury{white}{cr}Here you can buy serfs, choose "..
             "your noble, sound the alarm and later even set taxes.",
    },
    Administration = {
        de = "{grey}Verwaltung{white}{cr}Hier könnt Ihr Regularien "..
             "beschließen. Jede dieser Maßnahmen hat individuelle "..
             "Konsequenzen. Überlegt gut, ob und wann Ihr sie einsetzt.",
        en = "{grey}Administration{white}{cr}Here you can decide "..
             "regulations. Each of these measures has individual "..
             "consequences. Think carefully about whether and when "..
             "you use them.",
    },
}

Stronghold.Building.Text.TaxLevel = {
    [1] = {
        de = "{grey}Keine Steuer{white}{cr}Keine Steuern. Aber wie wollt Ihr zu Talern kommen?",
        en = "{grey}No Taxes{white}{cr}No taxes. But how are you going to generate money?",
    },
    [2] = {
        de = "{grey}Niedrige Steuer{white}{cr}Ihr seid großzügig und entlastet Eure Untertanen.",
        en = "{grey}Low Taxes{white}{cr}You are generous and exonerate your subjects.",
    },
    [3] = {
        de = "{grey}Faire Steuer{white}{cr}Ihr verlangt die übliche Steuer von Eurem Volk.",
        en = "{grey}Fair Taxes{white}{cr}You demand the usual tax from your people.",
    },
    [4] = {
        de = "{grey}Hohe Steuer{white}{cr}Ihr dreht an der Steuerschraube. Wenn das mal gut geht...",
        en = "{grey}High Taxes{white}{cr}You increase the tax burden. How long will this go well...",
    },
    [5] = {
        de = "{grey}Grausame Steuer{white}{cr}Ihr zieht Euren Untertanen das letzte Hemd aus!",
        en = "{grey}Curel Taxes{white}{cr}You are stripping your subjects of their last shirts!",
    },
}

Stronghold.Building.Text.Measure = {
    [BlessCategories.Construction] = {
        [1] = {
            de = "{grey}Zwangsabgabe{white}{cr}Treibt eine Sondersteuer von Eurem "..
                 "Volke ein. Ihren Ertrag vermag jedoch niemand vorherzusehen!",
            en = "{grey}Levy Duty{white}{cr}Collect a special tax from your people. "..
                 "However, no one can predict your yield!",
        },
        [2] = {
            de = "Die Siedler werden zur Kasse gebeten, was sie sehr verärgert!",
            en = "The settlers are asked to pay, which upsets them greatly!",
        },
        [3] = {de = "#Rank# ", en = "#Rank# ",},
    },
    [BlessCategories.Research] = {
        [1] = {
            de = "{grey}Öffentlicher Prozess{white}{cr}Haltet einen öffentlichen "..
                 "Schaupozess ab. Recht und Ordnung steigert die Zufriedenheit "..
                 "des Pöbel.",
            en = "{grey}Duty{white}{cr}Collect a special tax from your people. "..
                 "However, no one can predict your yield!",
        },
        [2] = {
            de = "Ihr sprecht Recht und bestraft Kriminelle. Das Volk begrüßt dies!",
            en = "You administer justice and punish criminals. The people welcome this!",
        },
        [3] = {de = "#Rank# ", en = "#Rank# ",},
    },
    [BlessCategories.Weapons] = {
        [1] = {
            de = "{grey}Willkommenskultur{white}{cr}Eure Migrationspolitik wird "..
                 "Neuankömmlinge sehr zufrieden machen, aber die Einheimischen "..
                 "werden dies nicht gut heißen...",
            en = "{grey}Welcome Culture{white}{cr}Your migration policies will keep "..
                 "newcomers very content but will also cause the locals to get very "..
                 "mad because of those \"guests\"...",
        },
        [2] = {
            de = "Eure Migrationspolitik wird von den zugezogenen Siedlern begrüßt.",
            en = "Your migration policy is welcomed by the new settlers.",
        },
        [3] = {de = "#Rank#, Festung ", en = "#Rank#, Fortress ",},
    },
    [BlessCategories.Financial] = {
        [1] = {
            de = "{grey}Folklorefest{white}{cr}Ihr beglückt eure Siedler mit einem "..
                 "rauschenden Fest, dass sie sehr glücklich machen wird.",
            en = "{grey}Folklorefest{white}{cr}You treat your settlers to a lavish "..
                 "festival that will make them very happy.",
        },
        [2] = {
            de = "Das Volksfest erfreut die Siedler und steigert Eure Beliebtheit.",
            en = "The folk festival delights the settlers and increases your popularity.",
        },
        [3] = {de = "#Rank#, Festung ", en = "#Rank#, Fortress ",},
    },
    [BlessCategories.Canonisation] = {
        [1] = {
            de = "{grey}Gelage{white}{cr}Erhaltet Ehre durch ein verschwenderisches Gelage. "..
                 "Aber Ihr zieht ebenso den Zorn des Volkes auf Euch!",
            en = "{grey}Feast{white}{cr}Gain honor from a lavish feast. But you draw the "..
                 "wrath of the people against you as well !",
        },
        [2] = {
            de = "Ein Bankett gereicht Euch an Ehre, aber verärgert das Volk!",
            en = "A banquet honors you, but angers the people!",
        },
        [3] = {de = "#Rank#, Zitadelle ", en = "#Rank#, Zitadel ",},
    },
}

Stronghold.Building.Text.PrayerMess = {
    [BlessCategories.Construction] = {
        [1] = {
            de = "{grey}Gebetsmesse{white}",
            en = "{grey}Church Service{white}",
        },
        [2] = {
            de = "Eure Priester leuten die Glocke zum Gebet.",
            en = "Your priests ring the bell for prayer.",
        },
        [3] = {de = "", en = "",},
    },
    [BlessCategories.Research] = {
        [1] = {
            de = "{grey}Ablassbriefe{white}",
            en = "{grey}Indulgence Letters{white}",
        },
        [2] = {
            de = "Eure Priester vergeben die Sünden Eurer Arbeiter.",
            en = "Your priests forgive the sins of your workers.",
        },
        [3] = {de = "", en = "",},
    },
    [BlessCategories.Weapons] = {
        [1] = {
            de = "{grey}Bibeln{white}",
            en = "{grey}Bible Reading{white}",
        },
        [2] = {
            de = "Eure Priester predigen Bibeltexte zu ihrer Gemeinde.",
            en = "Your priests read from the bible to their community.",
        },
        [3] = {de = "Kirche", en = "Church",},
    },
    [BlessCategories.Financial] = {
        [1] = {
            de = "{grey}Kollekte{white}",
            en = "{grey}Collect{white}",
        },
        [2] = {
            de = "Eure Priester rufen die Siedler auf zur Kollekte.",
            en = "Your priests are calling for the collection.",
        },
        [3] = {de = "Kirche", en = "Church",},
    },
    [BlessCategories.Canonisation] = {
        [1] = {
            de = "{grey}Heiligsprechung{white}",
            en = "{grey}Canonisation{white}",
        },
        [2] = {
            de = "Eure Priester sprechen Eure Taten heilig.",
            en = "Your priests sanctify your deeds.",
        },
        [3] = {de = "Kathedrale", en = "Cathedral",},
    },
}

