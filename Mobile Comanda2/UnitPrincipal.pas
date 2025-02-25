unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.Layouts,
  FMX.ListBox, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.ListView, System.JSON, System.Generics.Collections,
  FMX.Ani;

type
  TFrmPrincipal = class(TForm)
    Rectangle1: TRectangle;
    Label1: TLabel;
    TabControl: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    rect_abas: TRectangle;
    Rectangle3: TRectangle;
    Label2: TLabel;
    Rectangle4: TRectangle;
    Label3: TLabel;
    Z: TLayout;
    Label4: TLabel;
    edt_comanda: TEdit;
    rect_add_item: TRectangle;
    Label5: TLabel;
    rect_detalhes: TRectangle;
    Label6: TLabel;
    lb_mapa: TListBox;
    Rectangle6: TRectangle;
    lv_produto: TListView;
    edt_busca_produto: TEdit;
    rect_busca_produto: TRectangle;
    Label7: TLabel;
    img_aba1: TImage;
    img_aba2: TImage;
    img_aba3: TImage;
    AnimationMenu: TFloatAnimation;
    rectreservas: TRectangle;
    Label8: TLabel;
    layout_principal: TLayout;
    rectmovimento: TRectangle;
    Label10: TLabel;
    Circle1: TCircle;
    procedure img_aba1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rect_detalhesClick(Sender: TObject);
    procedure rect_add_itemClick(Sender: TObject);
    procedure lb_mapaItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure FormResize(Sender: TObject);
    procedure rect_busca_produtoClick(Sender: TObject);
    procedure lv_produtoPaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure edt_busca_produtoTyping(Sender: TObject);
    procedure img_menuClick(Sender: TObject);
    procedure AnimationMenuFinish(Sender: TObject);
  private
    procedure MudarAba(img: TImage);
    procedure DetalhesComanda(comanda: string);
    procedure AddMapa(comanda: string; status: string; valor_total: double);
    procedure AddProdutoLv(id_produto: integer; descricao: string;
      preco: double);
    procedure ListarProduto(ind_clear: boolean; busca: string);
    procedure CarregarComanda;
    procedure ThreadEnd(Sender: TObject);
    procedure ListarProdutoBusca(ind_clear: boolean; busca: string);
    { Private declarations }
  public
    { Public declarations }

    procedure AddItem(comanda: string);
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses UnitAddItem, UnitResumo, UnitDM;


procedure TFrmPrincipal.CarregarComanda;
var
    jsonArray: TJsonArray;
    erro: string;
    x : integer;
begin

    lb_mapa.Items.Clear;

    if dm.ListarComanda(jsonArray, erro) = false then
    begin
        showmessage(erro);
        exit;
    end else


    while not dm.tblmesas.Eof do
    begin

        AddMapa(inttostr(dm.tblmesas.FieldByName('codigo').AsInteger),
                dm.tblmesas.FieldByName('SITUACAO').AsString,
                dm.tblmesas.FieldByName('TOTAL').AsFloat);
                dm.tblmesas.Next;

    end;

    jsonArray.DisposeOf;
end;

procedure TFrmPrincipal.MudarAba(img: TImage);
begin
    img_aba1.Opacity := 0.4;
    img_aba2.Opacity := 0.4;
    img_aba3.Opacity := 0.4;

    if (dm.supervisor = 's') or (dm.supervisor = 'S') then begin
      rectmovimento.Enabled := true;
      rectmovimento.Visible := true;
    end;


    img.Opacity := 1;
    TabControl.GotoVisibleTab(img.Tag, TTabTransition.Slide);

    if img.Tag = 1 then
       CarregarComanda;
end;

procedure TFrmPrincipal.AddItem(comanda: string);
begin
    if NOT Assigned(FrmAddItem) then
        Application.CreateForm(TFrmAddItem, FrmAddItem);

    FrmAddItem.comanda := comanda;
    FrmAddItem.TabControl.ActiveTab := FrmAddItem.TabCategoria;
    FrmAddItem.Show;
end;

procedure TFrmPrincipal.AddMapa(comanda: string;
                                status: string;
                                valor_total: double);
var
    item: TListBoxItem;
    rect: TRectangle;
    lbl : TLabel;
begin
    // Item da lista...
    item := TListBoxItem.Create(lb_mapa);
    item.Text := '';
    item.Height := 110;
    item.TagString := comanda;
    item.Selectable := false;

    // Retangulo de fundo...
    rect := TRectangle.Create(item);
    rect.Parent := item;
    rect.Align := TAlignLayout.Client;
    rect.Margins.Top := 10;
    rect.Margins.Bottom := 10;
    rect.Margins.Left := 10;
    rect.Margins.Right := 10;
    rect.Fill.Kind := TBrushKind.Solid;
    rect.HitTest := false;

    if status = 'L' then
        rect.Fill.Color := $FF4A70F7  // azul...
    else
        rect.Fill.Color := $FFEC6E73; // vermelho...

    rect.XRadius := 10;
    rect.YRadius := 10;
    rect.Stroke.Kind := TBrushKind.None;

    // Label status...
    lbl := TLabel.Create(rect);
    lbl.Parent := rect;
    lbl.Align := TAlignLayout.Top;

    if status = 'L' then
        lbl.Text := 'Livre'
    else
        lbl.Text := 'Ocupada';


    lbl.Margins.Left := 5;
    lbl.Margins.Top := 5;
    lbl.Height := 15;
    lbl.StyledSettings := lbl.StyledSettings - [TStyledSetting.FontColor];
    lbl.FontColor := $FFFFFFFF;

    // Label valor...
    lbl := TLabel.Create(rect);
    lbl.Parent := rect;
    lbl.Align := TAlignLayout.Bottom;

    if status = 'L' then
        lbl.Text := ''
    else
        lbl.Text := FormatFloat('#,##0.00', valor_total);

    lbl.Margins.Right := 5;
    lbl.Margins.Bottom := 5;
    lbl.Height := 15;
    lbl.StyledSettings := lbl.StyledSettings - [TStyledSetting.FontColor];
    lbl.FontColor := $FFFFFFFF;
    lbl.TextAlign := TTextAlign.Trailing;

    // Label comanda...
    lbl := TLabel.Create(rect);
    lbl.Parent := rect;
    lbl.Align := TAlignLayout.Client;
    lbl.Text := comanda;
    lbl.StyledSettings := lbl.StyledSettings - [TStyledSetting.FontColor,
                                                TStyledSetting.Size];
    lbl.FontColor := $FFFFFFFF;
    lbl.Font.Size := 30;
    lbl.TextAlign := TTextAlign.Center;
    lbl.VertTextAlign := TTextAlign.Center;

    lb_mapa.AddObject(item);
end;

procedure TFrmPrincipal.DetalhesComanda(comanda: string);
begin
    if NOT Assigned(FrmResumo) then
        Application.CreateForm(TFrmResumo, FrmResumo);

    FrmResumo.lbl_comanda.Text := comanda;
    FrmResumo.Show;
end;

procedure TFrmPrincipal.edt_busca_produtoTyping(Sender: TObject);
begin
   if edt_busca_produto.text <> '' then begin
     ListarProdutoBusca(true, edt_busca_produto.Text);
   end else if edt_busca_produto.text = '' then begin
     ListarProduto(true, edt_busca_produto.Text);
   end;
end;

procedure TFrmPrincipal.AddProdutoLv(id_produto: integer;
                                     descricao: string;
                                     preco: double);
begin
    with lv_produto.Items.Add do
    begin
        Tag := id_produto;
        TListItemText(Objects.FindDrawable('TxtDescricao')).Text := descricao + ' - Pg: ' +
                                                                    lv_produto.Tag.ToString + ' / ' +
                                                                    Index.ToString;
        TListItemText(Objects.FindDrawable('TxtPreco')).Text := FormatFloat('#,##0.00', preco);
    end;
end;

procedure TFrmPrincipal.AnimationMenuFinish(Sender: TObject);
begin
    layout_principal.Enabled := AnimationMenu.Inverse;
    AnimationMenu.Inverse := NOT AnimationMenu.Inverse;
end;

procedure TFrmPrincipal.ThreadEnd(Sender: TObject);
begin
    lv_produto.EndUpdate;

    if Assigned(TThread(Sender).FatalException) then
        showmessage('Erro na carga dos produtos: ' + Exception(TThread(Sender).FatalException).Message);

end;

procedure TFrmPrincipal.ListarProduto(ind_clear: boolean; busca: string);
var
        x : integer;
        jsonArray: TJSONArray;
        erro: string;
begin


  if ind_clear = true then
  begin
    lv_produto.ScrollTo(0);
    lv_produto.Tag := 0;
    lv_produto.Items.Clear;
  end;

  if dm.ListarProduto(0, '', 0, jsonArray, erro) then
  begin
    if not dm.tblprodutos.IsEmpty then begin

     while not dm.tblprodutos.Eof do
     begin
       AddProdutoLv(dm.tblprodutos.FieldByName('codigo').AsInteger,
       dm.tblprodutos.FieldByName('descricao').AsString,
       dm.tblprodutos.FieldByName('pr_venda').AsFloat);
       dm.tblprodutos.Next;
     end;

    end;

  end else
    raise Exception.Create('Erro ao listar produto: ' + erro);
    exit;
end;


procedure TFrmPrincipal.ListarProdutoBusca(ind_clear: boolean; busca: string);
var
    jsonArray: TJsonArray;
    erro: string;
begin

  if ind_clear = true then
  begin
    lv_produto.ScrollTo(0);
    lv_produto.Tag := 0;
    lv_produto.Items.Clear;
  end;

  if dm.ListarProdutoBusca(0, busca, 0, jsonArray, erro) then
  begin
   if not dm.tblprodutos.IsEmpty then begin

      while not dm.tblprodutos.Eof do
    begin
      AddProdutoLv(dm.tblprodutos.FieldByName('codigo').AsInteger,
      dm.tblprodutos.FieldByName('descricao').AsString,
      dm.tblprodutos.FieldByName('pr_venda').AsFloat);
      dm.tblprodutos.Next;
    end;

   end else
     ListarProduto(true,'');
  end else
    raise Exception.Create('Erro ao listar produto: ' + erro);
    exit;

end;

procedure TFrmPrincipal.lv_produtoPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin


//    ShowMessage('Entrei no paint do produto e n�o sei pq');
 {   if (lv_produto.Items.Count >= 0) and (lv_produto.Tag >= 0) then
         if lv_produto.GetItemRect(lv_produto.Items.Count - 3).Bottom <= lv_produto.Height then
            ListarProduto(true, '');  }
 end;

procedure TFrmPrincipal.rect_add_itemClick(Sender: TObject);
begin
    if edt_comanda.Text <> '' then
        AddItem(edt_comanda.Text);
end;

procedure TFrmPrincipal.rect_busca_produtoClick(Sender: TObject);
begin
   ListarProdutoBusca(true, edt_busca_produto.Text);
end;

procedure TFrmPrincipal.rect_detalhesClick(Sender: TObject);
begin
    if edt_comanda.Text <> '' then
        DetalhesComanda(edt_comanda.Text);
end;

procedure TFrmPrincipal.FormResize(Sender: TObject);
begin
    lb_mapa.Columns := Trunc(lb_mapa.Width / 110);
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin

   MudarAba(img_aba1);
end;



procedure TFrmPrincipal.img_aba1Click(Sender: TObject);
begin
    MudarAba(TImage(Sender));
end;

procedure TFrmPrincipal.img_menuClick(Sender: TObject);
begin
  AnimationMenu.Start;
end;

procedure TFrmPrincipal.lb_mapaItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
    //DetalhesComanda(Item.TagString);

    if NOT Assigned(FrmResumo) then
        Application.CreateForm(TFrmResumo, FrmResumo);

    FrmResumo.lbl_comanda.Text := Item.TagString;
    FrmResumo.ShowModal(procedure(ModalResult: TModalResult)
    begin
        CarregarComanda;
    end);
end;

end.
