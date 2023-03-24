--- 
--- Hero Script
---
--- This script implements all processes around the hero.
---
--- Managed by the script:
--- - Stats of hero
--- - Stats of summons
--- - Selection of hero
--- - Activated abilities
--- - Passive abilities
--- - Selection menus
--- 

Stronghold = Stronghold or {};

Stronghold.Hero = {
    SyncEvents = {},
    Data = {
        ConvertBlacklist = {},
    },
    Config = {
        Rule = {
            Lord = {
                {Entities.PU_Hero1c,             true},
                {Entities.PU_Hero2,              true},
                {Entities.PU_Hero3,              true},
                {Entities.PU_Hero4,              true},
                {Entities.PU_Hero5,              true},
                {Entities.PU_Hero6,              true},
                {Entities.CU_BlackKnight,        true},
                {Entities.CU_Mary_de_Mortfichet, true},
                {Entities.CU_Barbarian_Hero,     true},
                {Entities.PU_Hero10,             true},
                {Entities.PU_Hero11,             true},
                {Entities.CU_Evil_Queen,         true},
            },
        },

        ---

        Text = {

        },

        UI = {
            TypeToBuyHeroButton = {
                [Entities.PU_Hero1c]             = "BuyHeroWindowBuyHero1",
                [Entities.PU_Hero2]              = "BuyHeroWindowBuyHero5",
                [Entities.PU_Hero3]              = "BuyHeroWindowBuyHero4",
                [Entities.PU_Hero4]              = "BuyHeroWindowBuyHero3",
                [Entities.PU_Hero5]              = "BuyHeroWindowBuyHero2",
                [Entities.PU_Hero6]              = "BuyHeroWindowBuyHero6",
                [Entities.CU_Mary_de_Mortfichet] = "BuyHeroWindowBuyHero7",
                [Entities.CU_BlackKnight]        = "BuyHeroWindowBuyHero8",
                [Entities.CU_Barbarian_Hero]     = "BuyHeroWindowBuyHero9",
                [Entities.PU_Hero10]             = "BuyHeroWindowBuyHero10",
                [Entities.PU_Hero11]             = "BuyHeroWindowBuyHero11",
                [Entities.CU_Evil_Queen]         = "BuyHeroWindowBuyHero12",
            },
            Player = {
                [1] = {
                    de = "%s %s {grey}hat einen Adligen gewählt.",
                    en = "%s %s {grey}has choosen a Noble.",
                },
                [2] = {
                    de = "%s %s{white}muss sich in die Burg zurückziehen!",
                    en = "%s %s{white}has to retreat to the castle!",
                },
            },
            Promotion = {
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

            HeroSkill = {
                [Entities.PU_Hero5]              = {
                    de = "{grey}Pfeilhagel{cr}{white}Ari lässt einen Köcher voll Pfeile auf die Gegner herabregnen.",
                    en = "{grey}Arrow Hail{cr}{white}Ari launches a quiver full of arrows on enemy troops.",
                },
                [Entities.CU_Mary_de_Mortfichet] = {
                    de = "{grey}Demoralisieren{cr}{white}Mary greift alle Feinde um sie herum an, was Opfer fordert und so die Kampfmoral der Feinde schwächt.",
                    en = "{grey}Demoralize{cr}{white}Mary attacks all enemies around her, which not only deals damage but also lowers the damage they can inflict.",
                },
            },

            HeroNames                            = {
                [Entities.PU_Hero1c]             = {
                    de = "DARIO, der könig ",
                    en = "DARIO, the king ",
                },
                [Entities.PU_Hero2]              = {
                    de = "PILGRIM, der geologe ",
                    en = "PILGRIM, the geologist ",
                },
                [Entities.PU_Hero3]              = {
                    de = "SALIM, der gelehrte ",
                    en = "SALIM, the scholar ",
                },
                [Entities.PU_Hero4]              = {
                    de = "EREC, der ritter ",
                    en = "EREC, the knight ",
                },
                [Entities.PU_Hero5]              = {
                    de = "ARI, die vogelfreie ",
                    en = "ARI, the vagabund ",
                },
                [Entities.PU_Hero6]              = {
                    de = "HELIAS, der priester ",
                    en = "HELIAS, the priest ",
                },
                [Entities.CU_Mary_de_Mortfichet] = {
                    de = "MARY, die schlange ",
                    en = "MARY, the snake ",
                },
                [Entities.CU_BlackKnight]        = {
                    de = "KERBEROS, der schrecken ",
                    en = "KERBEROS, the dread ",
                },
                [Entities.CU_Barbarian_Hero]     = {
                    de = "VARG, das wolfsblut ",
                    en = "VARG, the beastblood ",
                },
                [Entities.PU_Hero10]             = {
                    de = "DRAKE, der schakal ",
                    en = "DRAKE, the jackal ",
                },
                [Entities.PU_Hero11]             = {
                    de = "YUKI, die donnerfaust ",
                    en = "YUKI, the thunderfist ",
                },
                [Entities.CU_Evil_Queen]         = {
                    de = "KALA, die hexe ",
                    en = "KALA, the witch ",
                },
            },

            HeroBiography                        = {
                [Entities.PU_Hero1c]             = {
                    de = "Trotz seiner jungen Jahre obliegen die Geschicke des "..
                         "Reiches ihm. Früher wurde er oft dabei gesehen, wie "..
                         "er rosa Kleidchen trug. Die tauschte er inzwischen "..
                         "gegen ein Schwert ein. ",
                    en = "Despite his young age he has a lot of responsibility "..
                         "on his shoulders. He is often seen wearing pink dresses. "..
                         "Sometimes he exchanges them for armor and sword. ",
                },
                [Entities.PU_Hero2]              = {
                    de = "Er entstammt einer langen Linie von Bergmännern. Ein " ..
                         "glückliches Schicksal verhalf ihm zu Geld und Würden. "..
                         "Es fällt ihm oft schwer, seine Fahne vom Geruch des "..
                         "Sprengstoffs zu unterscheiden. ",
                    en = "He descended from a long line of miners. Serendipity "..
                         "helped him to money and dignity. He is always fond of "..
                         "alcohol. He often has trouble distinguishing the smell "..
                         "of the explosives from those of his mead. ",
                },
                [Entities.PU_Hero3]              = {
                    de = "Ein Schriftgelehrter aus dem nahen Osten. Manche sagen ihm nach, " ..
                         "er sei verrückt geworden und versuche in seinem Labor ein schwarzes "..
                         "Loch zu erschaffen und so die Vergangenheit zu verändern. ",
                    en = "A scholar from the east who decided to bring knowledge to the west. "..
                         "Some say he is crazy and tries to create a black hole inside his "..
                         "laboratory to alter time. ",
                },
                [Entities.PU_Hero4]              = {
                    de = "Er ist ein echter Ritter. Von Kopf bis Fuß gehüllt in glänzender "..
                         "Rüstung zieht er aus, seinen Ruhm zu mehren und Jungfrauen in " ..
                         "Nöten beizustehen. Seine Anwesenheit inspiriert die Truppen zu "..
                         "Höchsleistungen. ",
                    en = "He is a true knight. From head to toe clad in shining armor he strifes "..
                         "to gather fame and safe damsels in distress. His presence inspires all "..
                         "soldiers under his command. ",
                },
                [Entities.PU_Hero5]              = {
                    de = "Als Kind wurde sie von Gesetzlosen adoptiert und wuchs nicht nur " ..
                         "zu einer atemberaubenden Lady heran. Aber dies ist mit Nichten ihre " ..
                         "einzige Qualität, was sie jeden spüren lässt, der sich erdreistet, " ..
                         "ihre Augen eine Etage tiefer zu suchen. ",
                    en = "As a little girl she was adopted by the outlaws. Since then she grew "..
                         "to be a breathtaking lady. Beauty is not her only quality. Anyone who "..
                         "dares to search her eyes one story to deep will regret it. ",
                },
                [Entities.PU_Hero6]              = {
                    de = "Einst vorgesehen für die Thronfolge des Alten Reiches, war der Ruf des " ..
                         "Herrn stärker. Wenn er nicht gerade Wasser predigt und Wein trinkt, "..
                         "erfreut er sich an den lieblichen Klängen der Chorknaben. ",
                    en = "Once designated as the heir of the Old Reich the calling from god was "..
                         "stronger. When he is not preaching water and drinking wine he enjoys "..
                         "the lovely sounds of the choirboys. ",
                },
                [Entities.CU_Mary_de_Mortfichet] = {
                    de = "Die Countess ist verrufen als ruchloses Miststück. Zeigt ihr Gegenüber " ..
                         "eine Schwäche, zögert sie nicht, sie auszunutzen. Ihr Motto: Ein gut " ..
                         "platzierter Dolch erreicht mehr als 1000 Schwerter. ",
                    en = "The Countess is infamous as beeing a nefarious and bitch. If her "..
                         "opponent has any weaknesses she will expoit it. A good placed dagger "..
                         "is better than 1000 swords. ",
                },
                [Entities.CU_BlackKnight]        = {
                    de = "Als sein Vater den Thron aufgab um Pfaffe zu werden, brach für " ..
                         "ihn eine Welt zusammen. Seinem Erbe beraubt, verfiel er der " ..
                         "Finsternis. Als Scherge eines bösen Königs wartet er auf seine Chance. ",
                    en = "After his father gave up the throne to become a priest the world "..
                         "came crashing down for him. Deprived of his inheritance he embraced "..
                         "the darkness. As minion of a evil king he awaits his chance. ",
                },
                [Entities.CU_Barbarian_Hero]     = {
                    de = "Als Baby wurde er von einer Alphawölfin gesäugt. Als zwölfjähriger "..
                         "Junge besiegte er einen Eisbären im Zweikampf und wurde daraufhin zum " ..
                         "Anführer aller Barbaren gekrönt. ",
                    en = "After he was suckled by a alpha wolf instead of a woman he grew to a "..
                         "strong boy who defeated a icebear after his twelth birthday. He was "..
                         "soon chosen as the sole leader of the Barbarians. ",
                },
                [Entities.PU_Hero10]             = {
                    de = "Wenn er nicht gerade auf Haselnüsse und Tannenzapfen schießt, jagt " ..
                         "er als \"Der Schakal\" alle die behaupten, er wolle nur etwas "..
                         "kompensieren. Seine Mutter meint noch heute, er solle das Gewehr "..
                         "zuhause lassen. ",
                    en = "When he is not shooting at hazlenuts and pinecones he hunts down "..
                         "anyone as \"the jackal\" who dare to say he is compensating for "..
                         "something. His mother says to this day that he should leave his "..
                         "rifle at home. ",
                },
                [Entities.PU_Hero11]             = {
                    de = "Schon als kleines Mädchen beschäftigte sie sich mit Pyrotechnik. " ..
                         "Zusammen mit den drei Chinesen und deren Kontrabass verschlug es " ..
                         "sie in den Westen, wo sie Reichtum erlangte und nun eine Burg ihr "..
                         "Eigen nennt. ",
                    en = "She was engaged in pyrotechnics since early childhood. Together "..
                         "with the 3 Chinese and their double bass she ended up in the west "..
                         "searching for wealth. Now she claimed a castle. ",
                },
                [Entities.CU_Evil_Queen]         = {
                    de = "Um ihre Herkunft ranken sich Mysterien und düstere Legenden. Vom "..
                         "Nebelvolk wird sie wie eine Göttin verehrt. Böse Zungen behaupten, " ..
                         "sie hätte jeden Einzelnen ihrer Untertanen selbst zur Welt gebracht. ",
                    en = "Many rumors clowding the trugh about her origin. The shrouded praise "..
                         "her like a godess. Envy tongues claim that she had birthed the entirty "..
                         "of the shrouded pepole herself. ",
                },
            },

            HeroDescription = {
                [Entities.PU_Hero1c]             = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "Bastardschwertkämpfer, Hellebardiere "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Er besitzt die Autorität, schneller Maßnahmen zu ergreifen. "..
                         "Eure Maßnahmen sind doppelt so schneller einsetzbar. "..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Er kann feindliche Einheiten in einem weitem Umkreis vertreiben "..
                         "(außer Nebelvolk).",
                    en = "@color:55,145,155 Special units: @color:255,255,255 "..
                         "Bastardswordmen, Halberdiers "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "He has the autority to faster take measures when needed. "..
                         "Your measures can be used twice as often. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "He can inflict fear to enemies in a wide area "..
                         "(except the Shrouded).",
                },
                [Entities.PU_Hero2]              = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "- "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Seine Kenntnisse der Gesteine ermöglicht es, dass immer "..
                         "wenn Rohstoffe in Minen abgebaut werden, weitere Rohstoffe "..
                         "erzeugt werden. Ausbau der Minen steigert den Effekt. "..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Er kann eine Bombe legen, die verschüttete Schächte freilegt "..
                         "und ebenfalls Feinde schädigt. ",
                    en = "@color:55,145,155 Special units: @cr @color:255,255,255 "..
                         "- "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "Every time when resources are gathered by miners an aditional "..
                         "resource is earned. Upgrading mines increases this effect. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "He can place a bomb that damages foes and blast open resources.",
                },
                [Entities.PU_Hero3]              = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "- "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Wissen ist Macht. Und er weiß sein Wissen einzusetzen. Kanonen "..
                         "benötigen keine Ehre und die Kosten sind um 10% reduziert. "..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Er kann eine Falle verstecken, die explodiert, sobald der Feind "..
                         "unvorsichtig an sie heran tritt.",
                    en = "@color:55,145,155 Special units: @cr @color:255,255,255 "..
                         "- "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "Knowledge equals power. And he knows how to use it. Cannons do "..
                         "not require honor and their costs are reduced by 10%. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "He can hide a trap that explodes when reckless enemies come "..
                         "to close.",
                },
                [Entities.PU_Hero4]              = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "Berittene Streitaxtkämpfer und berittene Armbrustschützen, keine "..
                         "schweren Scharfschützen " ..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Er rekrutiert Soldaten mit der maximalen Erfahrung, wodurch die "..
                         "Ausbildung des Hauptmannes um 50% teurer wird. "..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Er kann mit einem Rundumschlag alle nahestehenden Feinde verletzen.",
                    en = "@color:55,145,155 Special units: @cr @color:255,255,255 "..
                         "Mounted axemen and mounted crossbowmen, no heavy sharpshooters "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "He will hire group leaders with full experience. But due to intensifyed "..
                         "training, the costs of those leaders increase by 50%. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "He can inflict high damage in a small area.",
                },
                [Entities.PU_Hero5]              = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "Leichte und schwere Banditen, Banditenbogenschützen "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Als Banditenfürstin kennt sie alle Tricks, um an Gold zu "..
                         "kommen. Die Steuereinnahmen werden um 30% erhöht. "..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Sie kann einen Pfeilhagel auf Feinde hernieder gehen lassen.",
                    en = "@color:55,145,155 Special units: @cr @color:255,255,255 "..
                         "Light and heavy bandits, bandit archers "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "Her upbringing taught her where to search for money. The tax income is "..
                         "increased by 30%. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "She can unleash a hail of arrows upon the enemy.",
                },
                [Entities.PU_Hero6]              = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "- "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Durch seinen Beistand brechen Arbeter seltener das Gesetz. "..
                         "Außerdem hat er eine geringe Chance, Feinde im Kampf zu "..
                         "bekehren. "..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Er kann die Rüstung von verbündeten Einheiten für einen "..
                         "kurzen Zeitruam verdoppeln.",
                    en = "@color:55,145,155 Special units: @cr @color:255,255,255 "..
                         "- "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "Workers are less likely to become criminals. Additionally "..
                         "he has a very slight to convert enemies while fighting them. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "He can bless allied troops, doubleing their armor raiting "..
                         "temporarily.",
                },
                [Entities.CU_Mary_de_Mortfichet] = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "Arbaleastschützen, keine schweren Scharfschützen "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Die Sabotage wird freigeschaltet, sobald sie gewählt wird. "..
                         "Diebe belegen weniger Platz und können bereits in Tavernen "..
                         "rekrutiert werden. "..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Sie hohlt zu einem Rundumschlag aus, der nahestehenden Feinde "..
                         "verletzt und die Angriffskraft der Überlebenden halbiert.",
                    en = "@color:55,145,155 Special units: @cr @color:255,255,255 "..
                         "Arbaleast archers, no heavy sharpshooters "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "She unlocks sabotage when chosen. Thieves occupy less population "..
                         "places and can be recruited without upgrading taverns. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "She can inflict damage to close enemies and also lower the "..
                         "damage surviving enemies inflict.",
                },
                [Entities.CU_BlackKnight]        = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "Leichte und schwere schwarze Ritter "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Er kann eine persönliche Leibgarde mit sich führen. Malus "..
                         "auf die Beliebtheit verringern sich um 40%. Dafür sinkt die "..
                         "maximale Beliebtheit sinkt auf 175. " ..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Er kann die Rüstung von nahestehenden Feinden zeitweilig auf 0 "..
                         "senken.",
                    en = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "Light and Heavy black knights "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "He can employ personal bodyguards. Negative effects on "..
                         "reputation are decreased by 40%. The reputation maximum becomes 175. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "He can temporarily reduce the armor of close by enemies to 0.",
                },
                [Entities.CU_Barbarian_Hero]     = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "Leichte und schwere Barbarenkrieger "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Einen Sieg muss man zu feiern wissen! Tavernen und Wirtshäuser "..
                         "produzieren doppelt so effektiv Beliebtheit. "..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Er ruft Wölfe herbei, die Ehre erzeugen, wenn sie gegen Feinde "..
                         "kämpfen. Ihre Stärke richtet sich nach seinem Rang.",
                    en = "@color:55,145,155 Special units: @cr @color:255,255,255 "..
                         "Light and heavy barbarian warriors "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "Barbarians know how to celebrate a victory. The efficiency "..
                         "of all taverns and ins are doubled. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "He cann summon wolves. They produce honor when they fight "..
                         "against an enemy. Their depends on his rank.",
                },
                [Entities.PU_Hero10]             = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "- "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Seine effizienteren Trainingsmethoden senken die Zeit für "..
                         "die Ausbildung von Scharfschützen um 50% und ihren Sold um 30%. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Er kann den Schaden von verbündeten Fernkämpfern in seiner "..
                         "Nähe kurzzeitig um 150% erhöhen.",
                    en = "@color:55,145,155 Special units: @cr @color:255,255,255 "..
                         "- "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "Through the efficient methods he lowers the training time of "..
                         "all sharpshooters by 50% and their upkeep costs by 30%. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "He can increase the damage of allied ranged troops that are "..
                         "close to him by 150% for a short amount of time.",
                },
                [Entities.PU_Hero11]             = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "- "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Die maximale Beliebtheit wird 300. Sie gewährt einmalig 100 "..
                         "Beliebtheit, sobald sie erscheint. Soldaten für einen Hauptmann "..
                         "anzuwerben ist 10% billiger. "..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Sie kann feindliche Einheiten in einem weitem Umkreis vertreiben "..
                         "(außer Nebelvolk).",
                    en = "@color:55,145,155 Special units: @cr @color:255,255,255 "..
                         "- "..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "The reputation limit is raised to 300. She gives a one time "..
                         "bonus of 100 reputation when selected. The costs of recruiting "..
                         "soldiers is reduced by 10%. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "She can inflict fear to enemies in a wide area "..
                         "(except the Shrouded).",
                },
                [Entities.CU_Evil_Queen]         = {
                    de = "@color:55,145,155 Spezialeinheiten: @cr @color:255,255,255 "..
                         "Bärenmenschen und Speerwerfer, keine Scharfschützen "..
                         "@cr @cr @color:255,255,255 " ..
                         "@color:55,145,155 Passive Fähigkeit: @cr @color:255,255,255 "..
                         "Die gesteigerte Geburtenrate sorgt für einen demographischen "..
                         "Wandel. Sie steigert Euer Bevölkerungslimit um 25%. "..
                         "@cr @cr "..
                         "@color:55,145,155 Aktive Fähigkeit: @cr @color:255,255,255 "..
                         "Sie kann nahestehende Feinde mit Gift schädigen.",
                    en = "@color:55,145,155 Special units: @cr @color:255,255,255 "..
                         "Bearmen and javelin throwers but no sharpshooters "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Passive Ability: @cr @color:255,255,255 "..
                         "The increased birth rate is causing demographic change. She "..
                         "increases your attraction limit by 25%. "..
                         "@cr @cr @color:255,255,255 "..
                         "@color:55,145,155 Active Ability: @cr @color:255,255,255 "..
                         "She can inflict poison damage to enemies.",
                },
            },
        },
    }
}

-- -------------------------------------------------------------------------- --
-- API

--- Creates an hero for the player.
function PlayerCreateNoble(_PlayerID, _Type, _Position)
    Stronghold.Hero:BuyHeroCreateNoble(_PlayerID, _Type, _Position);
end

--- Returns if the player has the type as hero.
function PlayerHasHeroOfType(_PlayerID, _Type)
    return Stronghold.Hero:HasValidHeroOfType(_PlayerID, _Type);
end

-- -------------------------------------------------------------------------- --

function Stronghold.Hero:Install()
    for i= 1, table.getn(Score.Player) do
        self.Data[i] = {};
    end

    self:ConfigureBuyHero();
    self:OverrideCalculationCallbacks();
    self:CreateHeroButtonHandlers();
    self:OverrideHero5AbilityArrowRain();
    self:OverrideHero8AbilityMoralDamage();
end

function Stronghold.Hero:OnSaveGameLoaded()
    for i= 1, table.getn(Score.Player) do
        local Wolves = {Logic.GetPlayerEntities(i, Entities.CU_Barbarian_Hero_wolf, 48)};
        for j=2, Wolves[1] +1 do
            self:ConfigurePlayersHeroPet(Wolves[j]);
        end
    end
end

function Stronghold.Hero:SetEntityConvertable(_EntityID, _Flag)
    self.Data.ConvertBlacklist[_EntityID] = _Flag == true;
end

function Stronghold.Hero:SetHeroName(_Type, _Text)
    local Text = _Text;
    if type(Text) ~= "table" then
        Text = {de = _Text, en = _Text};
    end
    self.Config.UI.HeroName[_Type] = Text;
end

function Stronghold.Hero:SetHeroBiography(_Type, _Text)
    local Text = _Text;
    if type(Text) ~= "table" then
        Text = {de = _Text, en = _Text};
    end
    self.Config.UI.HeroBiography[_Type] = Text;
end

function Stronghold.Hero:SetHeroDescription(_Type, _Text)
    local Text = _Text;
    if type(Text) ~= "table" then
        Text = {de = _Text, en = _Text};
    end
    self.Config.UI.HeroDescription[_Type] = Text;
end

-- -------------------------------------------------------------------------- --
-- Hero Selection

function Stronghold.Hero:OnSelectLeader(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not Stronghold:IsPlayer(PlayerID) or Logic.IsLeader(_EntityID) == 0 then
        return;
    end

    XGUIEng.SetWidgetPosition("Command_Attack", 4, 4);
    XGUIEng.SetWidgetPosition("Command_Stand", 38, 4);
    XGUIEng.SetWidgetPosition("Command_Defend", 72, 4);
    XGUIEng.SetWidgetPosition("Command_Patrol", 106, 4);
    XGUIEng.SetWidgetPosition("Command_Guard", 140, 4);
    XGUIEng.SetWidgetPosition("Formation01", 4, 38);
    XGUIEng.ShowWidget("Selection_MilitaryUnit", 1);

    XGUIEng.TransferMaterials("Research_Gilds", "Formation01");
    XGUIEng.ShowWidget("Selection_Leader", 1);

    local ShowFormations = 0;
    XGUIEng.ShowWidget("Commands_Leader", ShowFormations);
    for i= 1, 4 do
        XGUIEng.ShowWidget("Formation0" ..i, 1);
        if XGUIEng.IsButtonDisabled("Formation0" ..i) == 1 then
            if Logic.IsTechnologyResearched(PlayerID, Technologies.GT_StandingArmy) == 1 then
                XGUIEng.DisableButton("Formation0" ..i, 0);
            end
        end
    end
end

function Stronghold.Hero:OnSelectHero(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    if not Stronghold:IsPlayer(PlayerID) or Logic.IsHero(_EntityID) == 0 then
        return;
    end

    XGUIEng.SetWidgetPosition("Command_Attack", 4, 4);
    XGUIEng.SetWidgetPosition("Command_Stand", 38, 4);
    XGUIEng.SetWidgetPosition("Command_Defend", 72, 4);
    XGUIEng.SetWidgetPosition("Command_Patrol", 106, 4);
    XGUIEng.SetWidgetPosition("Command_Guard", 140, 4);
    XGUIEng.SetWidgetPosition("Formation01", 404, 4);
    XGUIEng.ShowWidget("Formation01", 0);
    XGUIEng.ShowWidget("Formation02", 0);
    XGUIEng.ShowWidget("Formation03", 0);
    XGUIEng.ShowWidget("Formation04", 0);

    self:OnSelectHero1(_EntityID);
    self:OnSelectHero2(_EntityID);
    self:OnSelectHero3(_EntityID);
    self:OnSelectHero4(_EntityID);
    self:OnSelectHero5(_EntityID);
    self:OnSelectHero6(_EntityID);
    self:OnSelectHero7(_EntityID);
    self:OnSelectHero8(_EntityID);
    self:OnSelectHero9(_EntityID);
    self:OnSelectHero10(_EntityID);
    self:OnSelectHero11(_EntityID);
    self:OnSelectHero12(_EntityID);
end

function Stronghold.Hero:OnSelectHero1(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    local TypeName = Logic.GetEntityTypeName(Type);
    if string.find(TypeName, "^PU_Hero1[abc]+$") then
        XGUIEng.SetWidgetPosition("Hero1_RechargeProtectUnits", 4, 38);
        XGUIEng.SetWidgetPosition("Hero1_ProtectUnits", 4, 38);
        XGUIEng.ShowWidget("Hero1_RechargeSendHawk", 0);
        XGUIEng.ShowWidget("Hero1_SendHawk", 0);
        XGUIEng.ShowWidget("Hero1_LookAtHawk", 0);
    end
end

function Stronghold.Hero:OnSelectHero2(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero2 then
        XGUIEng.SetWidgetPosition("Hero2_RechargePlaceBomb", 4, 38);
        XGUIEng.SetWidgetPosition("Hero2_PlaceBomb", 4, 38);
        XGUIEng.ShowWidget("Hero2_RechargeBuildCannon", 0);
        XGUIEng.ShowWidget("Hero2_BuildCannon", 0);
    end
end

function Stronghold.Hero:OnSelectHero3(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero3 then
        XGUIEng.SetWidgetPosition("Hero3_RechargeBuildTrap", 4, 38);
        XGUIEng.SetWidgetPosition("Hero3_BuildTrap", 4, 38);
        XGUIEng.ShowWidget("Hero3_RechargeHeal", 0);
        XGUIEng.ShowWidget("Hero3_Heal", 0);
    end
end

function Stronghold.Hero:OnSelectHero4(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero4 then
        XGUIEng.SetWidgetPosition("Hero4_RechargeCircularAttack", 4, 38);
        XGUIEng.SetWidgetPosition("Hero4_CircularAttack", 4, 38);
        XGUIEng.ShowWidget("Hero4_RechargeAuraOfWar", 0);
        XGUIEng.ShowWidget("Hero4_AuraOfWar", 0);
    end
end

function Stronghold.Hero:OnSelectHero5(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero5 then
        XGUIEng.SetWidgetPosition("Hero5_RechargeSummon", 4, 38);
        XGUIEng.SetWidgetPosition("Hero5_Summon", 4, 38);
        XGUIEng.SetWidgetPosition("Hero5_RechargeArrowRain", 4, 38);
        XGUIEng.SetWidgetPosition("Hero5_ArrowRain", 4, 38);
        XGUIEng.ShowWidget("Hero5_RechargeCamouflage", 0);
        XGUIEng.ShowWidget("Hero5_Camouflage", 0);
        XGUIEng.ShowWidget("Hero5_RechargeSummon", 0);
        XGUIEng.ShowWidget("Hero5_Summon", 0);
    end
end

function Stronghold.Hero:OnSelectHero6(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero6 then
        XGUIEng.SetWidgetPosition("Hero6_RechargeBless", 4, 38);
        XGUIEng.SetWidgetPosition("Hero6_Bless", 4, 38);
        XGUIEng.ShowWidget("Hero6_RechargeConvertSettler", 0);
        XGUIEng.ShowWidget("Hero6_ConvertSettler", 0);
    end
end

function Stronghold.Hero:OnSelectHero7(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_BlackKnight then
        XGUIEng.SetWidgetPosition("Hero7_RechargeMadness", 4, 38);
        XGUIEng.SetWidgetPosition("Hero7_Madness", 4, 38);
        XGUIEng.ShowWidget("Hero7_RechargeInflictFear", 0);
        XGUIEng.ShowWidget("Hero7_InflictFear", 0);
        XGUIEng.ShowWidget("Buy_Soldier", 1);
        XGUIEng.ShowWidget("Buy_Soldier_Button", 1);
    end
end

function Stronghold.Hero:OnSelectHero8(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_Mary_de_Mortfichet then
        XGUIEng.SetWidgetPosition("Hero8_RechargeMoraleDamage", 4, 38);
        XGUIEng.SetWidgetPosition("Hero8_MoraleDamage", 4, 38);
        XGUIEng.ShowWidget("Hero8_RechargePoison", 0);
        XGUIEng.ShowWidget("Hero8_Poison", 0);
    end
end

function Stronghold.Hero:OnSelectHero9(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_Barbarian_Hero then
        XGUIEng.SetWidgetPosition("Hero9_RechargeCallWolfs", 4, 38);
        XGUIEng.SetWidgetPosition("Hero9_CallWolfs", 4, 38);
        XGUIEng.ShowWidget("Hero9_RechargeBerserk", 0);
        XGUIEng.ShowWidget("Hero9_Berserk", 0);
    end
end

function Stronghold.Hero:OnSelectHero10(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero10 then
        XGUIEng.SetWidgetPosition("Hero10_RechargeLongRangeAura", 4, 38);
        XGUIEng.SetWidgetPosition("Hero10_LongRangeAura", 4, 38);
        XGUIEng.ShowWidget("Hero10_RechargeSniperAttack", 0);
        XGUIEng.ShowWidget("Hero10_SniperAttack", 0);
    end
end

function Stronghold.Hero:OnSelectHero11(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.PU_Hero11 then
        XGUIEng.SetWidgetPosition("Hero11_RechargeFireworksFear", 4, 38);
        XGUIEng.SetWidgetPosition("Hero11_FireworksFear", 4, 38);
        XGUIEng.ShowWidget("Hero11_RechargeShuriken", 0);
        XGUIEng.ShowWidget("Hero11_RechargeFireworksMotivate", 0);
        XGUIEng.ShowWidget("Hero11_Shuriken", 0);
        XGUIEng.ShowWidget("Hero11_FireworksMotivate", 0);
    end
end

function Stronghold.Hero:OnSelectHero12(_EntityID)
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_Evil_Queen then
        XGUIEng.SetWidgetPosition("Hero12_RechargePoisonRange", 4, 38);
        XGUIEng.SetWidgetPosition("Hero12_PoisonRange", 4, 38);
        XGUIEng.ShowWidget("Hero12_RechargePoisonArrows", 0);
        XGUIEng.ShowWidget("Hero12_PoisonArrows", 0);
    end
end

function Stronghold.Hero:PrintSelectionName()
    local EntityID = GUI.GetSelectedEntity();
    local PlayerID = Logic.EntityGetPlayer(EntityID);
    if Stronghold:IsPlayer(PlayerID) then
		if EntityID == GetID(Stronghold.Players[PlayerID].LordScriptName) then
            local Type = Logic.GetEntityType(EntityID);
            local TypeName = Logic.GetEntityTypeName(Type);
            local Name = XGUIEng.GetStringTableText("Names/" ..TypeName);
            local CurrentRank = GetRank(PlayerID);
            local Text = GetRankName(CurrentRank, PlayerID);
            XGUIEng.SetText("Selection_Name", Text.. " " ..Name);
		end
    end
end

-- -------------------------------------------------------------------------- --
-- Buy Hero

function Stronghold.Hero:ConfigureBuyHero()
    Overwrite.CreateOverwrite("GameCallback_Logic_BuyHero_OnHeroSelected", function(_PlayerID, _ID, _Type)
        if Stronghold:IsPlayer(_PlayerID) then
            Stronghold.Hero:BuyHeroSetupNoble(_PlayerID, _ID, _Type);
            Stronghold.Hero:PlayFunnyComment(_PlayerID);
            Stronghold.Hero:InitSpecialUnits(_PlayerID, _Type);
            return;
        end
        return Overwrite.CallOriginal();
    end);

    Overwrite.CreateOverwrite("GameCallback_GUI_BuyHero_GetHeadline", function(_PlayerID)
        if Stronghold:IsPlayer(_PlayerID) then
            local LordID = GetID(Stronghold.Players[_PlayerID].LordScriptName);
            local Caption = (LordID ~= 0 and "Alea Iacta Est!") or "Wählt Euren Adligen!";
            return Caption;
        end
        return Overwrite.CallOriginal();
    end);

    Overwrite.CreateOverwrite("GameCallback_GUI_BuyHero_GetMessage", function(_PlayerID, _Type)
        if Stronghold:IsPlayer(_PlayerID) then
            local Lang = GetLanguage();
            local DisplayName = Stronghold.Hero.Config.UI.HeroNames[_Type][Lang];
            local Biography = Stronghold.Hero.Config.UI.HeroBiography[_Type][Lang];
            local Description = Stronghold.Hero.Config.UI.HeroDescription[_Type][Lang];
            return string.format(
                "%s @cr @cr @color:180,180,180 %s @cr @cr %s",
                DisplayName,
                Biography,
                Description
            );
        end
        return Overwrite.CallOriginal();
    end);
end

function Stronghold.Hero:BuyHeroCreateNoble(_PlayerID, _Type, _Position)
    if Stronghold:IsPlayer(_PlayerID) then
        local Position = _Position;
        if type(Position) ~= "table" then
            Position = GetPosition(Position);
        end
        local ID = Logic.CreateEntity(_Type, Position.X, Position.Y, 0, _PlayerID);
        self:BuyHeroSetupNoble(_PlayerID, ID, _Type, true);
        self:InitSpecialUnits(_PlayerID, _Type);
    end
end

function Stronghold.Hero:BuyHeroSetupNoble(_PlayerID, _ID, _Type, _Silent)
    if Stronghold:IsPlayer(_PlayerID) then
        -- Get motivation cap
        local ExpectedSoftCap = 2;
        local CurrentSoftCap = CUtil.GetPlayersMotivationSoftcap(_PlayerID);
        -- Set name of lord
        Logic.SetEntityName(_ID, Stronghold.Players[_PlayerID].LordScriptName);
        -- Display info message
        if not _Silent then
            local Language = GetLanguage();
            local PlayerName = UserTool_GetPlayerName(_PlayerID);
            local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
            Message(string.format(self.Config.UI.Player[1][Language], PlayerColor, PlayerName));
        end

        if _Type == Entities.PU_Hero11 then
            -- Update motivation soft cap
            ExpectedSoftCap = 3;
            -- Give motivation for Yuki
            Stronghold:UpdateMotivationOfPlayersWorkers(_PlayerID, 50);
            Stronghold:AddPlayerReputation(_PlayerID, 100);
        end
        if _Type == Entities.CU_BlackKnight then
            -- Update motivation soft cap
            ExpectedSoftCap = 1.75;
            -- Create guard for Kerberos
            Tools.CreateSoldiersForLeader(_ID, 3);
            Logic.LeaderChangeFormationType(_ID, 1);
        end

        -- Call hero selected callbacks
        CUtil.AddToPlayersMotivationSoftcap(_PlayerID, ExpectedSoftCap - CurrentSoftCap);
        if _PlayerID == GUI.GetPlayerID() or GUI.GetPlayerID() == 17 then
            Stronghold.Building:OnHeadquarterSelected(GUI.GetSelectedEntity());
        end
    end
end

-- The wolves of Varg becoming stronger when he gets higher titles.
function Stronghold.Hero:ConfigurePlayersHeroPet(_EntityID)
    local PlayerID = Logic.EntityGetPlayer(_EntityID);
    local Type = Logic.GetEntityType(_EntityID);
    if Type == Entities.CU_Barbarian_Hero_wolf then
        if self:HasValidHeroOfType(PlayerID, Entities.CU_Barbarian_Hero) then
            local CurrentRank = GetRank(PlayerID);
            local Armor = 2 + math.floor(CurrentRank * 0.5);
            local Damage = 13 + math.floor(CurrentRank * 3);
            Logic.SetSpeedFactor(_EntityID, 1.1 + ((CurrentRank -1) * 0.04));
            SVLib.SetEntitySize(_EntityID, 1.1 + ((CurrentRank -1) * 0.04));
            CEntity.SetArmor(_EntityID, Armor);
            CEntity.SetDamage(_EntityID, Damage);
        end
    end
end

-- Play a funny comment when the hero is selected.
-- (Yes, it is intended that every player hears them.)
function Stronghold.Hero:PlayFunnyComment(_PlayerID)
    local FunnyComment = Sounds.VoicesHero1_HERO1_FunnyComment_rnd_01;
    local LordID = GetID(Stronghold.Players[_PlayerID].LordScriptName);
    local Type = Logic.GetEntityType(LordID);
    if Type == Entities.PU_Hero2 then
        FunnyComment = Sounds.VoicesHero2_HERO2_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero3 then
        FunnyComment = Sounds.VoicesHero3_HERO3_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero4 then
        FunnyComment = Sounds.VoicesHero4_HERO4_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero5 then
        FunnyComment = Sounds.VoicesHero5_HERO5_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero6 then
        FunnyComment = Sounds.VoicesHero6_HERO6_FunnyComment_rnd_01;
    elseif Type == Entities.CU_BlackKnight then
        FunnyComment = Sounds.VoicesHero7_HERO7_FunnyComment_rnd_01;
    elseif Type == Entities.CU_Mary_de_Mortfichet then
        FunnyComment = Sounds.VoicesHero8_HERO8_FunnyComment_rnd_01;
    elseif Type == Entities.CU_Barbarian_Hero then
        FunnyComment = Sounds.VoicesHero9_HERO9_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero10 then
        FunnyComment = Sounds.AOVoicesHero10_HERO10_FunnyComment_rnd_01;
    elseif Type == Entities.PU_Hero11 then
        FunnyComment = Sounds.AOVoicesHero11_HERO11_FunnyComment_rnd_01;
    elseif Type == Entities.CU_Evil_Queen then
        FunnyComment = Sounds.AOVoicesHero12_HERO12_FunnyComment_rnd_01;
    end
    Sound.PlayQueuedFeedbackSound(FunnyComment, 127);
end

function Stronghold.Hero:InitSpecialUnits(_PlayerID, _Type)
    Stronghold.Recruitment:InitDefaultRoster(_PlayerID);

    local ThiefRecruiter = {Entities.PB_Tavern2};
    if string.find(Logic.GetEntityTypeName(_Type), "PU_Hero1") then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.PU_LeaderPoleArm4;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.PU_LeaderSword4;
    elseif _Type == Entities.PU_Hero2 then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow2"] = Entities.PU_LeaderBow2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow3"] = Entities.PU_LeaderBow3;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeRifle1"] = Entities.PU_LeaderRifle1;
    elseif _Type == Entities.PU_Hero4 then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow2"] = Entities.PU_LeaderBow2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow3"] = Entities.PU_LeaderBow3;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeRifle1"] = Entities.PU_LeaderRifle1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeCavalryHeavy1"] = Entities.PU_LeaderHeavyCavalry2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeCavalryLight1"] = Entities.PU_LeaderCavalry2;
    elseif _Type == Entities.PU_Hero5 then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword3"] = Entities.CU_BanditLeaderSword2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.CU_BanditLeaderSword1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow1"] = Entities.CU_BanditLeaderBow1;
    elseif _Type == Entities.CU_BlackKnight then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.CU_BlackKnight_LeaderMace2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.CU_BlackKnight_LeaderMace1;
    elseif _Type == Entities.CU_Mary_de_Mortfichet then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow3"] = Entities.PU_LeaderBow4;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeRifle1"] = Entities.PU_LeaderRifle1;
        ResearchTechnology(Technologies.T_ThiefSabotage, _PlayerID);
        ThiefRecruiter = {Entities.PB_Tavern1, Entities.PB_Tavern2};
    elseif _Type == Entities.CU_Barbarian_Hero then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.CU_Barbarian_LeaderClub2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.CU_Barbarian_LeaderClub1;
    elseif _Type == Entities.CU_Evil_Queen then
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword1"] = Entities.PU_LeaderPoleArm1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword2"] = Entities.PU_LeaderPoleArm2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSword3"] = Entities.CU_Evil_LeaderBearman1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeSpear1"] = Entities.PU_LeaderSword3;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow2"] = Entities.PU_LeaderBow2;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeBow3"] = Entities.CU_Evil_LeaderSkirmisher1;
        Stronghold.Recruitment.Data[_PlayerID].Roster["Research_UpgradeRifle1"] = Entities.PU_LeaderBow3;
    end
    Stronghold.Recruitment.Data[_PlayerID].Config[Entities.PU_Thief].RecruiterBuilding = ThiefRecruiter;
end

-- -------------------------------------------------------------------------- --
-- Trigger

function Stronghold.Hero:EntityAttackedController(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        for k,v in pairs(Stronghold.Players[_PlayerID].AttackMemory) do
            -- Count down and remove
            Stronghold.Players[_PlayerID].AttackMemory[k][1] = v[1] -1;
            if Stronghold.Players[_PlayerID].AttackMemory[k][1] <= 0 then
                Stronghold.Players[_PlayerID].AttackMemory[k] = nil;
            end

            -- Teleport to HQ
            if Logic.IsHero(k) == 1 then
                if Logic.GetEntityHealth(k) == 0 then
                    Stronghold.Players[_PlayerID].AttackMemory[k] = nil;
                    local PlayerColor = "@color:"..table.concat({GUI.GetPlayerColor(_PlayerID)}, ",");
                    local x,y,z = Logic.EntityGetPos(k);

                    -- Send message
                    local Language = GetLanguage();
                    local TypeName = Logic.GetEntityTypeName(Logic.GetEntityType(k));
                    local Name = XGUIEng.GetStringTableText("Names/" ..TypeName);
                    Message(string.format(self.Config.UI.Player[2][Language], PlayerColor, Name));
                    -- Place hero
                    Logic.CreateEffect(GGL_Effects.FXDieHero, x, y, _PlayerID);
                    local ID = SetPosition(k, Stronghold.Players[_PlayerID].DoorPos);
                    if Logic.GetEntityType(ID) == Entities.CU_BlackKnight then
                        Logic.LeaderChangeFormationType(ID, 1);
                    end
                    Logic.HurtEntity(ID, Logic.GetEntityHealth(ID));
                end
            end

            if not IsExisting(k) then
                Stronghold.Players[_PlayerID].AttackMemory[k] = nil;
            end
        end
    end
end

function Stronghold.Hero:HeliasConvertController(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        for k,v in pairs(Stronghold.Players[_PlayerID].AttackMemory) do
            if Logic.GetEntityType(k) == Entities.PU_Hero6 then
                local HeliasPlayerID = Logic.EntityGetPlayer(k);
                local AttackerID = v[2];
                if Logic.IsEntityInCategory(AttackerID, EntityCategories.Soldier) == 1 then
                    AttackerID = SVLib.GetLeaderOfSoldier(AttackerID);
                end
                if not self.Data.ConvertBlacklist[AttackerID] then
                    if Logic.GetEntityHealth(AttackerID) > 0 and Logic.IsHero(AttackerID) == 0 then
                        if math.random(1, 1000) <= 3 and GetDistance(AttackerID, k) <= 1000 then
                            ChangePlayer(AttackerID, HeliasPlayerID);
                            if GUI.GetPlayerID() == HeliasPlayerID then
                                Sound.PlayFeedbackSound(Sounds.VoicesHero6_HERO6_ConvertSettler_rnd_01, 0);
                            end
                        end
                    end
                end
            end
        end
    end
end

function Stronghold.Hero:VargWolvesController(_PlayerID)
    if Stronghold:IsPlayer(_PlayerID) then
        local WolvesBatteling = 0;
        for k,v in pairs(GetPlayerEntities(_PlayerID, Entities.CU_Barbarian_Hero_wolf)) do
            local Task = Logic.GetCurrentTaskList(v);
            if Task and string.find(Task, "BATTLE") then
                WolvesBatteling = WolvesBatteling +1;
            end
        end
        Stronghold.Economy:AddOneTimeHonor(_PlayerID, 0.05 * WolvesBatteling);
    end
end

-- -------------------------------------------------------------------------- --
-- Activated Abilities

function Stronghold.Hero:OverrideHero5AbilityArrowRain()
    function GUIAction_Hero5ArrowRain()
        GUI.ActivateShurikenCommandState();
	    GUI.State_SetExclusiveMessageRecipient(HeroSelection_GetCurrentSelectedHeroID());
    end
    Overwrite.CreateOverwrite("GUITooltip_NormalButton", function(_TextKey, _ShortCut)
        Overwrite.CallOriginal();
        if _TextKey == "AOMenuHero5/command_poisonarrows" then
            local Language = GetLanguage();
            local Text = Stronghold.Hero.Config.UI.HeroSkill[Entities.PU_Hero5][Language];
            ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name")..
                ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]";

            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Placeholder.Replace(Text));
            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
        end
    end);
end

function Stronghold.Hero:OverrideHero8AbilityMoralDamage()
    function GUIAction_Hero8MoraleDamage()
        local HeroID = HeroSelection_GetCurrentSelectedHeroID();
        GUI.SettlerCircularAttack(HeroID);
        GUI.SettlerAffectUnitsInArea(HeroID);
    end
    Overwrite.CreateOverwrite("GUITooltip_NormalButton", function(_TextKey, _ShortCut)
        Overwrite.CallOriginal();
        if _TextKey == "MenuHero8/command_moraledamage" then
            local Language = GetLanguage();
            local Text = Stronghold.Hero.Config.UI.HeroSkill[Entities.CU_Mary_de_Mortfichet][Language];
            ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name")..
                ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]";

            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, Placeholder.Replace(Text));
            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, "");
            XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip);
        end
    end);
end

-- -------------------------------------------------------------------------- --
-- Passive Abilities

function Stronghold.Hero:OverrideCalculationCallbacks()
    -- Generic --
    Overwrite.CreateOverwrite("GameCallback_GainedResources", function(_PlayerID, _ResourceType, _Amount)
        Overwrite.CallOriginal();
        if Stronghold:IsPlayer(_PlayerID) then
            Stronghold.Hero:ResourceProductionBonus(_PlayerID, _ResourceType, _Amount);
        end
    end);

    -- Noble --

    Overwrite.CreateOverwrite("GameCallback_Calculate_ReputationMax", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMaxReputationPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_ReputationIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyReputationIncreasePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_DynamicReputationIncrease", function(_PlayerID, _BuildingID, _WorkerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyDynamicReputationBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_ReputationDecrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyReputationDecreasePassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_HonorIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyHonorBonusPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_DynamicHonorIncrease", function(_PlayerID, _BuildingID, _WorkerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyDynamicHonorBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, CurrentAmount);
        return CurrentAmount;
    end);

    -- Money --

    Overwrite.CreateOverwrite("GameCallback_Calculate_TotalPaydayIncome", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyIncomeBonusPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_TotalPaydayUpkeep", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyUpkeepDiscountPassiveAbility(_PlayerID, _CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_PaydayUpkeep", function(_PlayerID, _UnitType, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyUnitUpkeepDiscountPassiveAbility(_PlayerID, _UnitType, CurrentAmount)
        return CurrentAmount;
    end);

    -- Attraction --

    Overwrite.CreateOverwrite("GameCallback_Calculate_CivilAttrationLimit", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMaxCivilAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_CivilAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyCivilAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_MilitaryAttrationLimit", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMaxMilitaryAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_MilitaryAttrationUsage", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMilitaryAttractionPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    -- Social --

    Overwrite.CreateOverwrite("GameCallback_Calculate_MeasureIncrease", function(_PlayerID, _CurrentAmount)
        local CurrentAmount = Overwrite.CallOriginal();
        CurrentAmount = Stronghold.Hero:ApplyMeasurePointsPassiveAbility(_PlayerID, CurrentAmount);
        return CurrentAmount;
    end);

    Overwrite.CreateOverwrite("GameCallback_Calculate_CrimeRate", function(_PlayerID, _Rate)
        local CrimeRate = Overwrite.CallOriginal();
        CrimeRate = Stronghold.Hero:ApplyCrimeRatePassiveAbility(_PlayerID, CrimeRate);
        return CrimeRate;
    end);
end

function Stronghold.Hero:HasValidHeroOfType(_PlayerID, _Type)
    if Stronghold:IsPlayer(_PlayerID) then
        local LordID = GetID(Stronghold.Players[_PlayerID].LordScriptName);
        if IsEntityValid(LordID) then
            local HeroType = Logic.GetEntityType(LordID);
            local TypeName = Logic.GetEntityTypeName(HeroType);
            if type(_Type) == "string" and TypeName and string.find(TypeName, _Type) then
                return true;
            elseif type(_Type) == "number" and HeroType == _Type then
                return true;
            end
        end
    end
    return false;
end

-- Passive Ability: Resource production bonus
-- (Callback is only called for main resource types)
-- TODO: Replace this with server functions?
function Stronghold.Hero:ResourceProductionBonus(_PlayerID, _Type, _Amount)
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero2) then
        if _Amount >= 4 then
            if _Type == ResourceType.SulfurRaw
            or _Type == ResourceType.ClayRaw
            or _Type == ResourceType.StoneRaw
            or _Type == ResourceType.IronRaw then
                -- TODO: Maybe use the non-raw here?
                Logic.AddToPlayersGlobalResource(_PlayerID, _Type, math.max(_Amount-3, 1));
            end
        end
    end
end

-- Passive Ability: leader costs
function Stronghold.Hero:ApplyLeaderCostPassiveAbility(_PlayerID, _Type, _Costs)
    local Costs = _Costs;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero4) then
        local IsCannon = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Cannon) == 1
        local IsScout = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Scout) == 1
        local IsThief = Logic.IsEntityTypeInCategory(_Type, EntityCategories.Thief) == 1
        if not IsCannon and not IsScout and not IsThief then
            if Costs[ResourceType.Gold] then
                Costs[ResourceType.Gold] = math.ceil(Costs[ResourceType.Gold] * 1.5);
            end
            if Costs[ResourceType.Clay] then
                Costs[ResourceType.Clay] = math.ceil(Costs[ResourceType.Clay] * 1.5);
            end
            if Costs[ResourceType.Wood] then
                Costs[ResourceType.Wood] = math.ceil(Costs[ResourceType.Wood] * 1.5);
            end
            if Costs[ResourceType.Stone] then
                Costs[ResourceType.Stone] = math.ceil(Costs[ResourceType.Stone] * 1.5);
            end
            if Costs[ResourceType.Iron] then
                Costs[ResourceType.Iron] = math.ceil(Costs[ResourceType.Iron] * 1.5);
            end
            if Costs[ResourceType.Sulfur] then
                Costs[ResourceType.Sulfur] = math.ceil(Costs[ResourceType.Sulfur] * 1.5);
            end
        end
    end
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero3) then
        if Logic.IsEntityTypeInCategory(_Type, EntityCategories.Cannon) == 1 then
            Costs[ResourceType.Honor] = nil;
            Costs[ResourceType.Gold] = math.ceil(Costs[ResourceType.Gold] * 0.9);
            Costs[ResourceType.Wood] = math.ceil(Costs[ResourceType.Wood] * 0.9);
            Costs[ResourceType.Iron] = math.ceil(Costs[ResourceType.Iron] * 0.9);
            Costs[ResourceType.Sulfur] = math.ceil(Costs[ResourceType.Sulfur] * 0.9);
        end
    end
    return Costs;
end

-- Passive Ability: soldier costs
function Stronghold.Hero:ApplySoldierCostPassiveAbility(_PlayerID, _LeaderType, _Costs)
    local Costs = _Costs;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero11) then
        if Costs[ResourceType.Gold] then
            Costs[ResourceType.Gold] = math.ceil(Costs[ResourceType.Gold] * 0.9);
        end
        if Costs[ResourceType.Clay] then
            Costs[ResourceType.Clay] = math.ceil(Costs[ResourceType.Clay] * 0.9);
        end
        if Costs[ResourceType.Wood] then
            Costs[ResourceType.Wood] = math.ceil(Costs[ResourceType.Wood] * 0.9);
        end
        if Costs[ResourceType.Stone] then
            Costs[ResourceType.Stone] = math.ceil(Costs[ResourceType.Stone] * 0.9);
        end
        if Costs[ResourceType.Iron] then
            Costs[ResourceType.Iron] = math.ceil(Costs[ResourceType.Iron] * 0.9);
        end
        if Costs[ResourceType.Sulfur] then
            Costs[ResourceType.Sulfur] = math.ceil(Costs[ResourceType.Sulfur] * 0.9);
        end
    end
    return Costs;
end

function Stronghold.Hero:ApplyRecruitTimePassiveAbility(_PlayerID, _LeaderType, _Value)
    local Value = _Value;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero10) then
        if Logic.IsEntityTypeInCategory(_LeaderType, EntityCategories.Rifle) == 1 then
            Value = Value * 0.5;
        end
    end
    return Value;
end

-- Passive Ability: Change civil places usage
function Stronghold.Hero:ApplyCivilAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    -- Do nothing
    return Value;
end

-- Passive Ability: Increase of max civil attraction
function Stronghold.Hero:ApplyMaxCivilAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidHeroOfType(_PlayerID, Entities.CU_Evil_Queen) then
        Value = Value * 1.25;
    end
    return Value;
end

-- Passive Ability: Change millitary places usage
function Stronghold.Hero:ApplyMilitaryAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if Stronghold.Hero:HasValidHeroOfType(_PlayerID, Entities.CU_Mary_de_Mortfichet) then
        local ThiefCount = Logic.GetNumberOfEntitiesOfTypeOfPlayer(_PlayerID, Entities.PU_Thief);
        Value = Value - (ThiefCount * 3);
    end
    return Value;
end

-- Passive Ability: Increase of max military attraction
function Stronghold.Hero:ApplyMaxMilitaryAttractionPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    -- Do nothing
    return Value;
end

-- Passive Ability: Increase of reputation
function Stronghold.Hero:ApplyMaxReputationPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidHeroOfType(_PlayerID, Entities.CU_BlackKnight) then
        Value = 175;
    elseif self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero11) then
        Value = 300;
    end
    return Value;
end

-- Passive Ability: Increase of reputation
function Stronghold.Hero:ApplyReputationIncreasePassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    -- Do nothing
    return Value;
end

-- Passive Ability: Decrease of reputation
function Stronghold.Hero:ApplyReputationDecreasePassiveAbility(_PlayerID, _Decrease)
    local Decrease = _Decrease;
    if self:HasValidHeroOfType(_PlayerID, Entities.CU_BlackKnight) then
        Decrease = Decrease * 0.6;
    end
    return Decrease;
end

-- Passive Ability: Improve dynamic reputation generation
function Stronghold.Hero:ApplyDynamicReputationBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, _Amount)
    local Value = _Amount;
    if self:HasValidHeroOfType(_PlayerID, Entities.CU_Barbarian_Hero) then
        local Type = Logic.GetEntityType(_BuildingID);
        if Type == Entities.PB_Tavern1 or Type == Entities.PB_Tavern2 then
            Value = Value * 2;
        end
    end
    return Value;
end

-- Passive Ability: Honor increase bonus
function Stronghold.Hero:ApplyHonorBonusPassiveAbility(_PlayerID, _Income)
    local Income = _Income;
    -- do nothing
    return Income;
end

-- Passive Ability: Improve dynamic honor generation
function Stronghold.Hero:ApplyDynamicHonorBonusPassiveAbility(_PlayerID, _BuildingID, _WorkerID, _Amount)
    local Value = _Amount;
    if self:HasValidHeroOfType(_PlayerID, Entities.CU_Barbarian_Hero) then
        local Type = Logic.GetEntityType(_BuildingID);
        if Type == Entities.PB_Tavern1 or Type == Entities.PB_Tavern2 then
            Value = Value * 2;
        end
    end
    return Value;
end

-- Passive Ability: Tax income bonus
function Stronghold.Hero:ApplyIncomeBonusPassiveAbility(_PlayerID, _Income)
    local Income = _Income;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero5) then
        Income = Income * 1.3;
    end
    return Income;
end

-- Passive Ability: Upkeep discount
function Stronghold.Hero:ApplyUpkeepDiscountPassiveAbility(_PlayerID, _Upkeep)
    local Upkeep = _Upkeep;
    -- do nothing
    return Upkeep;
end

-- Passive Ability: Upkeep discount
-- This function is called for each unit type individually.
function Stronghold.Hero:ApplyUnitUpkeepDiscountPassiveAbility(_PlayerID, _Type, _Upkeep)
    local Upkeep = _Upkeep;
    -- if self:HasValidHeroOfType(_PlayerID, Entities.CU_Mary_de_Mortfichet) then
    --     if _Type == Entities.PU_Scout or _Type == Entities.PU_Thief then
    --         Upkeep = 0;
    --     end
    -- end
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero10) then
        if _Type == Entities.PU_LeaderRifle1 or _Type == Entities.PU_LeaderRifle2 then
            Upkeep = Upkeep * 0.7;
        end
    end
    return Upkeep;
end

-- Passive Ability: Generating measure points
function Stronghold.Hero:ApplyMeasurePointsPassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidHeroOfType(_PlayerID, "^PU_Hero1[abc]+$") then
        Value = Value * 2.0;
    end
    return Value;
end

-- Passive Ability: Change factor of becoming a criminal
function Stronghold.Hero:ApplyCrimeRatePassiveAbility(_PlayerID, _Value)
    local Value = _Value;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero6) then
        Value = Value * 0.25;
    end
    return Value;
end

-- Passive Ability: Chance the chance of becoming a criminal
function Stronghold.Hero:ApplyCrimeChancePassiveAbility(_PlayerID, _Chance)
    local Value = _Chance;
    if self:HasValidHeroOfType(_PlayerID, Entities.PU_Hero6) then
        Value = Value * 0.75;
    end
    return Value;
end

