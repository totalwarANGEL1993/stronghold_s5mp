

Stronghold.Text = {};

Stronghold.Text.Promotion = {
    Requirements = {
        [1] = {de = "Burg", en = "Keep"},
        [2] = {de = "Festung", en = "Fortress"},
        [3] = {de = "Zitadelle", en = "Zitadel"},

        [4] = {de = "Kapelle", en = "Chapel"},
        [5] = {de = "Kirche", en = "Church"},
        [6] = {de = "Kathedrale", en = "Cathedral"},
    },

    NewRank = {
        [1] = {
            de = "@color:180,180,180 %s @color:255,255,255 @cr Erhebt Euren Adligen in einen "..
                 "höheren Adelsstand. @cr @color:244,184,0 benötigt: @color:255,255,255 %s",
            en = "@color:180,180,180 %s @color:255,255,255 @cr Promote your Noble to a higher "..
                 " peerage. @cr Requirements: %s",
        },
        [2] = {
            de = "@color:180,180,180 Höchster Rang @cr @color:255,255,255 Euer Adligen hat "..
                 "den höchsten Titel erreicht.",
            en = "@color:180,180,180 Highest Rank @cr @color:255,255,255 Your Noble reached "..
                 "the highest possible title.",
        },
    },

    Title = {
        [Rank.Commoner] = {
            [Gender.Male]   = {de = "Pöbel", en = "Rabble"},
            [Gender.Female] = {de = "Pöbel", en = "Rabble"}
        },
        [Rank.Noble]    = {
            [Gender.Male]   = {de = "Adliger", en = "Nobleman"},
            [Gender.Female] = {de = "Adlige", en = "Noblewoman"}
        },
        [Rank.Mayor]    = {
            [Gender.Male]   = {de = "Vogt", en = "Bailiff"},
            [Gender.Female] = {de = "Vögtin", en = "Bailiff"}
        },
        [Rank.Earl]     = {
            [Gender.Male]   = {de = "Fürst", en = "Lord"},
            [Gender.Female] = {de = "Fürstin", en = "Lady"}
        },
        [Rank.Baron]    = {
            [Gender.Male]   = {de = "Baron", en = "Baron"},
            [Gender.Female] = {de = "Baronin", en = "Baroness"}
        },
        [Rank.Count]    = {
            [Gender.Male]   = {de = "Graf", en = "Count"},
            [Gender.Female] = {de = "Gräfin", en = "Countess"}
        },
        [Rank.Margrave] = {
            [Gender.Male]   = {de = "Markgraf", en = "Margrave"},
            [Gender.Female] = {de = "Markgräfin", en = "Margravine"}
        },
        [Rank.Duke]     = {
            [Gender.Male]   = {de = "Herzog", en = "Duke"},
            [Gender.Female] = {de = "Herzogin", en = "Duchess"}
        },
    },
};

