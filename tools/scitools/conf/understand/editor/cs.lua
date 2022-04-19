-- C#
return {
  name = "C#",
  lexer = 3,
  extensions = "cs",
  keywords = {
    [0] = {
      name = "Primary Keywords",
      keywords =
        [[abstract as base bool break byte case catch char checked
        class const continue decimal default delegate do double
        else enum event explicit extern false finally fixed float
        for foreach goto if implicit in int interface internal
        is lock long namespace new null object operator out
        override params private protected public readonly ref
        return sbyte sealed short sizeof stackalloc static string
        struct switch this throw true try typeof uint ulong
        unchecked unsafe ushort using virtual void while]]
    },
    [1] = {
      name = "Secondary Keywords",
      keywords = [[]]
    },
    [2] = {
      name = "Doc Keywords",
      keywords = [[]]
    }
  },
  style = require "cxx_styles",
  comment = {
    line = "//"
  }
}
