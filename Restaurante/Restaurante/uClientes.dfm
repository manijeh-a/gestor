object frmClientes: TfrmClientes
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Comandas'
  ClientHeight = 343
  ClientWidth = 488
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object Panel5: TPanel
    Left = 0
    Top = 0
    Width = 488
    Height = 49
    Align = alTop
    BevelOuter = bvNone
    Color = 5592405
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 531
    DesignSize = (
      488
      49)
    object Label11: TLabel
      Left = 531
      Top = 22
      Width = 188
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Relat'#243'rio de Vendas no Per'#237'odo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 10066329
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ExplicitLeft = 813
    end
    object DBText2: TDBText
      Left = 16
      Top = -4
      Width = 83
      Height = 32
      AutoSize = True
      DataField = 'NOME'
      DataSource = dsMesa
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'Segoe UI Semilight'
      Font.Style = []
      ParentFont = False
    end
    object DBText3: TDBText
      Left = 16
      Top = 23
      Width = 69
      Height = 25
      AutoSize = True
      DataField = 'DATA'
      DataSource = dsMesa
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Image1: TImage
      Left = 404
      Top = 0
      Width = 84
      Height = 49
      Align = alRight
      Center = True
      Picture.Data = {
        0954506E67496D61676589504E470D0A1A0A0000000D49484452000000200000
        00200804000000D973B27F0000000467414D410000B18F0BFC61050000000262
        4B47440000AA8D2332000000097048597300000EC400000EC401952B0E1B0000
        000774494D4507E30A1F0C3812F3F2A833000002374944415478DAA5954F6C4C
        5114C67F27A1A6841DC5564AB50D226181489A88101A42229848946045225236
        62C36AD234111B8A062136D54422FE949096069B2EA811A69644D955D3998CC5
        75EE7BDA99F7E74EE7F1ADDE3DEF9CEF3BEF9C73CF136260E6D14A0B0D2C6491
        1EBF31CA475EF040C6A2BE12096EE034FB48C5F0E6B94B463E552030B3B9C071
        66E0C66F2E7156F2B1046629BD34313D86D925B9088159CD63E657116EF1932D
        32142050F5575587FB14EBFD2C3C0293E22D2B12845B7C608DAD854FD0C9C984
        E1161DD2EE1168E3DE57ACBC0B459A256709BA690BBCC892E1101B43EE432A93
        0E095D95A3A253371A1A9B837253AB729FCD65B63E7648C1DCE240C073823A31
        696E87B4FAB5498500851F9EE235AB42BE7BC55CE370E4EB26037C8AE029882B
        6206591753A0A71A9437B3E8A1869DDED33DB6C5F80D881961496C8D277571AA
        5BE4C48C33C7D1262F0BED924BDDE25725823E9BBC47D0C37687CFD8FF7EC267
        312FD9E052F792AF992A675C16FD62BA38E2549FBE8D97C5ECE74EC8F88C56C7
        203D890CF81E3BCADFA90D189B24EB18E536BA039E7694B5CAD7F5EA9423A3C3
        DDC9A690D60037686779C0D625C72CC132BD6733498E228DF2C55F281D9CFA07
        828C9C29ADB437AC4C183ECCDAA995A614F50C265AAA3F74A98ED887F2B5FE88
        0555876F0DADF5BF59F4D25C45F83B76FBEA2102A5A8E53C272A76A4C845CE49
        A16488FE5CEBF5E79A0E8D968F099DD94C49DB41E091CCD5FBDF4223752CD6E3
        575DBB599EF350C6A3BE7F00CA60CF1FC8041E30000000257445587464617465
        3A63726561746500323031392D31302D33315431323A35363A31382B30303A30
        3032D82A9D0000002574455874646174653A6D6F6469667900323031392D3130
        2D33315431323A35363A31382B30303A3030438592210000001974455874536F
        667477617265007777772E696E6B73636170652E6F72679BEE3C1A0000000049
        454E44AE426082}
      OnClick = Image1Click
      ExplicitLeft = 439
    end
  end
  object DBGridEh1: TDBGridEh
    Left = 0
    Top = 49
    Width = 488
    Height = 221
    Align = alClient
    BorderStyle = bsNone
    DataSource = dsPessoa
    DynProps = <>
    Flat = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    Options = [dgEditing, dgAlwaysShowEditor, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
    OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
    ParentFont = False
    TabOrder = 1
    TitleParams.Font.Charset = ANSI_CHARSET
    TitleParams.Font.Color = clWindowText
    TitleParams.Font.Height = -15
    TitleParams.Font.Name = 'Segoe UI Semilight'
    TitleParams.Font.Style = []
    TitleParams.ParentFont = False
    OnKeyPress = DBGridEh1KeyPress
    Columns = <
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'NOME'
        Footers = <>
        Width = 306
      end
      item
        CellButtons = <>
        DynProps = <>
        EditButtons = <>
        FieldName = 'TOTAL_RATEIO'
        Footers = <>
        Title.Caption = 'Valor Pago'
        Width = 135
      end>
    object RowDetailData: TRowDetailPanelControlEh
    end
  end
  object Panel7: TPanel
    Left = 0
    Top = 318
    Width = 488
    Height = 25
    Align = alBottom
    BevelOuter = bvNone
    Color = 5592405
    ParentBackground = False
    TabOrder = 2
    ExplicitWidth = 531
    DesignSize = (
      488
      25)
    object Label8: TLabel
      Left = 531
      Top = 22
      Width = 188
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Relat'#243'rio de Vendas no Per'#237'odo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 10066329
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ExplicitLeft = 813
    end
    object Splitter1: TSplitter
      Left = 0
      Top = 0
      Width = 13
      Height = 25
    end
    object Splitter2: TSplitter
      Left = 472
      Top = 0
      Width = 16
      Height = 25
      Align = alRight
      ExplicitLeft = 684
    end
    object Splitter3: TSplitter
      Left = 420
      Top = 0
      Width = 0
      Height = 25
      Align = alRight
      ExplicitLeft = 684
    end
    object Label9: TLabel
      Left = 420
      Top = 0
      Width = 52
      Height = 25
      Align = alRight
      Caption = 'F12 Sair'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = Label9Click
      ExplicitLeft = 463
      ExplicitHeight = 20
    end
    object Label1: TLabel
      Left = 13
      Top = 0
      Width = 4
      Height = 25
      Align = alLeft
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ExplicitHeight = 20
    end
    object btnFecharConta: TLabel
      Left = 17
      Top = 0
      Width = 188
      Height = 25
      Align = alLeft
      AutoSize = False
      Caption = 'F10 Fechar a Conta'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      OnClick = btnFecharContaClick
      ExplicitLeft = 232
    end
  end
  object pnTotal: TPanel
    Left = 0
    Top = 270
    Width = 488
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Color = 14581528
    ParentBackground = False
    TabOrder = 3
    object DBText1: TDBText
      Left = 382
      Top = 0
      Width = 106
      Height = 48
      Align = alRight
      AutoSize = True
      DataField = 'TRATEIO'
      DataSource = dsPessoa
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -29
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ExplicitLeft = 376
      ExplicitTop = 1
      ExplicitHeight = 40
    end
    object DBText4: TDBText
      Left = 94
      Top = 0
      Width = 106
      Height = 48
      Align = alLeft
      Alignment = taRightJustify
      AutoSize = True
      DataField = 'TOTAL'
      DataSource = dsComanda_Master
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -29
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ExplicitLeft = 115
      ExplicitTop = 1
      ExplicitHeight = 40
    end
    object Label3: TLabel
      Left = 0
      Top = 0
      Width = 94
      Height = 48
      Margins.Left = 5
      Align = alLeft
      Caption = 'TOTAL CONSUMO R$'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitHeight = 40
    end
    object Label2: TLabel
      Left = 322
      Top = 0
      Width = 60
      Height = 48
      Margins.Left = 5
      Align = alRight
      Caption = 'TOTAL PAGO R$'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      ExplicitLeft = 316
      ExplicitTop = 1
      ExplicitHeight = 40
    end
  end
  object dsPessoa: TDataSource
    DataSet = Dados.qryComanda_Pessoa
    Left = 216
    Top = 200
  end
  object dsMesa: TDataSource
    DataSet = Dados.qryMesas
    Left = 136
    Top = 192
  end
  object dsComanda_Master: TDataSource
    DataSet = Dados.qryComandas_master
    Left = 280
    Top = 192
  end
end