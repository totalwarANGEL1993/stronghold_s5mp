--- 
--- Text for Rights
--- 

Stronghold.Rights.Text = {
    RequireCastle = {
        [1] = {de = "Burg", en = "Keep"},
        [2] = {de = "Festung", en = "Fortress"},
        [3] = {de = "Zitadelle", en = "Zitadel"},
    },
    RequireCathedral = {
        [1] = {de = "Kapelle", en = "Chapel"},
        [2] = {de = "Kirche", en = "Church"},
        [3] = {de = "Kathedrale", en = "Cathedral"},
    },
    RequireTaxPayer = {
        de = "Zivilbevölkerung", en = "civil population",
    },
    RequireWorkplaces = {
        de = "Arbeitsstätten", en = "workplaces",
    },
    RequireBeautification = {
        [1] = {de = "Ziergebäude", en = "beautification"},
        [2] = {de = "Alle Ziergebäude", en = "all beautifications"},
    },
    RequireSoldiers = {
        de = "Militäreinheiten", en = "military units",
    },

    PromoteSelf = {
        de = "Erhebt Euch, %s!",
        en = "Rise, %!"
    },
    PromoteLocked = {
        de = "Hochwohlgeboren, Ihr könnt keinen höheren Titel beanspruchen!",
        en = "Your Highness, you can't obtain a higher title yet!"
    },
    PromoteOther = {
        de = "%s %s {grey} wurde befördert und ist nun{white}%s",
        en = "%s %s {grey}has been promoted and is now{white}%s"
    },
    NewRank = {
        de = "@color:180,180,180 %s @color:255,255,255 @cr Erhebt Euren Adligen in "..
             "höheren Stand. @cr @color:244,184,0 benötigt: @color:255,255,255 %s",
        en = "einen @color:180,180,180 %s @color:255,255,255 @cr Promote your Noble "..
             "to a higher  peerage. @cr Requirements: %s",
    },
    FinalRank = {
        de = "@color:180,180,180 Höchster Rang @cr @color:255,255,255 Euer Adliger "..
             "hat den höchsten Titel erreicht.",
        en = "@color:180,180,180 Highest Rank @cr @color:255,255,255 Your Noble "..
             "reached the highest possible title.",
    },

    Title = {
        [PlayerRank.Commoner] = {
            [Gender.Male]   = {de = "Gewöhnlicher", en = "Commoner"},
            [Gender.Female] = {de = "Gewöhnliche", en = "Commoner"}
        },
        [PlayerRank.Noble]    = {
            [Gender.Male]   = {de = "Adliger", en = "Nobleman"},
            [Gender.Female] = {de = "Adlige", en = "Noblewoman"}
        },
        [PlayerRank.Mayor]    = {
            [Gender.Male]   = {de = "Vogt", en = "Bailiff"},
            [Gender.Female] = {de = "Vögtin", en = "Bailiff"}
        },
        [PlayerRank.Earl]     = {
            [Gender.Male]   = {de = "Fürst", en = "Lord"},
            [Gender.Female] = {de = "Fürstin", en = "Lady"}
        },
        [PlayerRank.Baron]    = {
            [Gender.Male]   = {de = "Baron", en = "Baron"},
            [Gender.Female] = {de = "Baronin", en = "Baroness"}
        },
        [PlayerRank.Count]    = {
            [Gender.Male]   = {de = "Graf", en = "Count"},
            [Gender.Female] = {de = "Gräfin", en = "Countess"}
        },
        [PlayerRank.Margrave] = {
            [Gender.Male]   = {de = "Markgraf", en = "Margrave"},
            [Gender.Female] = {de = "Markgräfin", en = "Margravine"}
        },
        [PlayerRank.Duke]     = {
            [Gender.Male]   = {de = "Herzog", en = "Duke"},
            [Gender.Female] = {de = "Herzogin", en = "Duchess"}
        },
    },
}

