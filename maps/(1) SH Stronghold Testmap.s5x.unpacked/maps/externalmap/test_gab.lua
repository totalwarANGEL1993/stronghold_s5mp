function CreateDialogNpc1Npc()
    NonPlayerCharacter.Create {
        ScriptName = "dialogNpc1",
        Callback = CreateDialogNpc1Dialog
    };
    NonPlayerCharacter.Activate("dialogNpc1");
end

function CreateDialogNpc1Dialog()
    local Dialog = {};
    local AP = QuickDialog.AddPages(Dialog);

    AP {
        Title   = "Hurensohn",
        Text    = "Hallo, ich bin ein dummer Hurensohn!",
    }
    AP {
        Title   = "Held",
        Text    = "Aha? Das ist wirklich gut zu wissen.",
    }
    AP {
        Title   = "Hurensohn",
        Text    = "Ich suche mir jetzt eine Hure, mit der ich weitere mache.",
    }
    AP {
        Title   = "Test 1",
        Text    = "Eine weitere Seite...",
    }
    AP {
        Title   = "Test 2",
        Text    = "Eine weitere Seite...",
    }
    AP {
        Title   = "Test 3",
        Text    = "Eine weitere Seite...",
    }
    AP {
        Title   = "Test 4",
        Text    = "Eine weitere Seite...",
    }
    AP {
        Title   = "Test 5",
        Text    = "Eine weitere Seite...",
    }
    AP {
        Title   = "Test 6",
        Text    = "Eine weitere Seite...",
    }

    QuickDialog.Start(1, "TestDialog1", Dialog);
end

