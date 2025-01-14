unit Replicador.Model.Conexao.Firedac;

interface

uses
  Replicador.Model.Interfaces, Replicador.Model.Tipificacoes, Data.DB,
  Datasnap.DBClient,
  System.Classes, Replicador.Model.Query.Firedac,
  System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Comp.UI;

type
  TModelConexao = class(TInterfacedObject, IModelConexao)
  private
    FConexao: TFDConnection;
    FQuery: TList<IModelQuery>;
    FID : Integer;
    FTableReceive: String;
    FTableSend: String;
    FDescrition: String;
    FSend : Boolean;
    FReceive : Boolean;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    procedure SetConexao(const Value: TFDConnection);
    function GetConexao: TFDConnection;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    procedure SetDescrition(const Value: String);
    procedure SetTableReceive(const Value: String);
    procedure SetTableSend(const Value: String);
    function GetDescrition : String;
    function GetTableReceive : String;
    function GetTableSend : String;
    function GetConnectionStatus: Boolean;
    procedure SetConnectionStatus(const Value: Boolean);
    function GetReceive: Boolean;
    function GetSend: Boolean;
    procedure SetReceive(const Value: Boolean);
    procedure SetSend(const Value: Boolean);
    function GetTables(Tipo : String): TStringList;
    function fnc_buscarOrdemTabelas(Arquivo : String) : TStringList;
    function StartTransaction : IModelConexao;
    function Commit : IModelConexao;
    function Rollback : IModelConexao;
    function Connected(Value : Boolean) : iModelConexao;
    function Objecto : TObject;
    function Query(Value : Integer) : iModelQuery;
    function IdNewQuery : Integer;
  public
    constructor Create(TipsConexao : TTipsConexao);
    destructor Destroy; override;
    class function New(TipsConexao : TTipsConexao) : IModelConexao;
    function GetPrimaryKeys(Table : String) : TStringList;
    class procedure GravarLog(aString : String);
    property Conexao: TFDConnection read GetConexao write SetConexao;
    property ID : Integer read GetID write SetID;
    property Descrition : String read GetDescrition write SetDescrition;
    property TableReceive : String read GetTableReceive write SetTableReceive;
    property TableSend : String read GetTableSend write SetTableSend;
    property ConnectionStatus : Boolean read GetConnectionStatus write SetConnectionStatus;
    property Send : Boolean read GetSend write SetSend;
    property Receive : Boolean read GetReceive write SetReceive;
  end;

implementation

uses
  System.SysUtils, System.IniFiles;

{ TConexao }


function TModelConexao.Commit: IModelConexao;
begin
  Result := Self;
  FConexao.Commit;
end;

function TModelConexao.Connected(Value: Boolean): iModelConexao;
begin
  Result := Self;
  FConexao.Connected := Value;
end;

constructor TModelConexao.Create(TipsConexao : TTipsConexao);
begin
  Conexao := TFDConnection.Create(nil);
  FDPhysFBDriverLink1:= TFDPhysFBDriverLink.Create(nil);
  try
    FDPhysFBDriverLink1.VendorLib := TipsConexao.vendorlib;
    FQuery := TList<IModelQuery>.Create;
    ID := TipsConexao.ID;
    Conexao.Params.Database := TipsConexao.Database;
    Conexao.Params.DriverID := 'FB'; //TipsConexao.DriverID;
    Conexao.Params.UserName := TipsConexao.UserName;
    Conexao.Params.Password := TipsConexao.Password;
    Conexao.Params.Add('RoleName=' + TipsConexao.RoleName);
    Conexao.Params.Add('Protocol=TCPIP');
    Conexao.Params.Add('Server=' + TipsConexao.Server);
    Conexao.Params.Add('Port=' + TipsConexao.Port);
    //Conexao.ResourceOptions.CmdExecMode := amAsync;
    Conexao.Connected := true;
    Descrition := TipsConexao.Descrition;
    TableReceive := TipsConexao.TableReceive;
    TableSend := TipsConexao.TableSend;
    Send := TipsConexao.Send;
    Receive := TipsConexao.Receive;
  except
    //raise Exception.Create('N�o foi poss�vel conectar a base de dados');
  end;

end;

function TModelConexao.Objecto: TObject;
begin
  Result := FConexao;
end;

function TModelConexao.Query(Value : Integer) : iModelQuery;
begin
  while Pred(FQuery.Count) < Value do
  begin
    FQuery.Add(TModelQuery.New(Self));
  end;
  Result := FQuery[Value];
end;

function TModelConexao.Rollback: IModelConexao;
begin
  Result := Self;
  FConexao.Rollback;
end;

destructor TModelConexao.Destroy;
begin
  if Assigned(Conexao) then
    Conexao.Free;
  if Assigned(FQuery) then
    FreeAndNil(FQuery);
  inherited;
end;

function TModelConexao.GetConexao: TFDConnection;
begin
  Result := FConexao;
end;

function TModelConexao.GetConnectionStatus: Boolean;
begin
  Result := FConexao.Connected;
end;

function TModelConexao.GetDescrition: String;
begin
  Result := FDescrition;
end;

function TModelConexao.GetID: Integer;
begin
  Result := FID;
end;

function TModelConexao.GetPrimaryKeys(Table : String) : TStringList;
var
  SQL: string;
  intQuery : integer;
begin
  intQuery := FQuery.Count;
  Result := TStringList.Create;
  SQL := 'select                                                                        ' +
       '     s.rdb$field_name AS PK,                                                     ' +
       '     i.rdb$relation_name as TABELA                                               ' +
       ' from                                                                            ' +
       '     rdb$indices i                                                               ' +
       ' left join rdb$index_segments s on i.rdb$index_name = s.rdb$index_name           ' +
       ' left join rdb$relation_constraints rc on rc.rdb$index_name = i.rdb$index_name   ' +
       ' where                                                                           ' +
       '     rc.rdb$constraint_type = ''PRIMARY KEY'' AND                                ' +
       '     i.rdb$relation_name = ' + QuotedStr(Table) + '                              ';
    Query(intQuery).SQL.Text := SQL;
    Query(intQuery).Open;
    while not Query(intQuery).Eof do
    begin
      Result.Add('GID');
     // Result.Add(Query(intQuery).FieldByName('pk').Value);  // by marcelo 15_02_2020
      Query(intQuery).Next;
    end;
end;

function TModelConexao.GetReceive: Boolean;
begin
  Result := FReceive;
end;

function TModelConexao.GetSend: Boolean;
begin
  Result := FSend;
end;


function TModelConexao.GetTableReceive: String;
begin
  Result := FTableReceive;
end;

function TModelConexao.GetTables(Tipo : String): TStringList;
begin
  try
    Result := TStringList.Create;
    if Tipo = 'I' then
    begin
      Result := fnc_buscarOrdemTabelas('TABLE_INSERT_ORDER');
    end
    else if Tipo = 'D' then
      Result := fnc_buscarOrdemTabelas('TABLE_DELETE_ORDER');

  except on E : Exception do
    Self.GravarLog(E.Message);
  end;
end;

function TModelConexao.GetTableSend: String;
begin
  Result := FTableSend;
end;

class procedure TModelConexao.GravarLog(aString: String);
begin
  TThread.Queue(TThread.CurrentThread,
  procedure
  var
    arq: TextFile;
    NomeArq: string;
  begin
    if not DirectoryExists(ExtractFilePath(ParamStr(0)) + 'LOG') then
    CreateDir(ExtractFilePath(ParamStr(0)) + 'LOG');
    NomeArq := ExtractFilePath(ParamStr(0)) + 'LOG\LOG_' + FormatDateTime('dd_mm_yyyy', now) + '.txt';
    AssignFile(arq, NomeArq);
    if not FileExists(NomeArq) then Rewrite(arq) else Append(arq);
    Writeln(arq, FormatDateTime('hh:nn:ss', now) + ' - ' + aString);
    CloseFile(arq);
  end);

end;

function TModelConexao.IdNewQuery: Integer;
begin
  Result := FQuery.Count;
end;

function TModelConexao.fnc_buscarOrdemTabelas(Arquivo : String) : TStringList;
var
  I: Integer;
  Lista: TStringList;
  Ini: TIniFile;
  aSQL: string;
  intQuery: Integer;
begin
  Result := TStringList.Create;
  if FileExists(ExtractFileDir(ParamStr(0)) + '\'+Arquivo+'.ini') then
  begin
    Lista := TStringList.Create;
    Ini := TIniFile.Create(ExtractFileDir(ParamStr(0)) + '\'+Arquivo+'.ini');
    try
      Ini.ReadSection(Self.GetDescrition, Lista);
      for I := 0 to Pred(Lista.Count) do
        Result.Add(Ini.ReadString(Self.GetDescrition, Lista[I], ''));
    finally
      Ini.Free;
    end;
  end
  else
  begin
    intQuery := FQuery.Count;
    aSQL := 'select rdb$relation_name as tabela from rdb$relations where rdb$system_flag = 0';
    Query(intQuery).SQL.Text := aSQL;
    Query(intQuery).Open;
    while not Query(intQuery).eof do
    begin
      Result.Add(Query(intQuery).FieldByName('tabela').AsString);
      Query(intQuery).Next;
    end;
  end;
end;

class function TModelConexao.New(TipsConexao : TTipsConexao) : IModelConexao;
begin
  Result := TModelConexao.Create(TipsConexao);
end;

procedure TModelConexao.SetConexao(const Value: TFDConnection);
begin
  FConexao := Value;
end;

procedure TModelConexao.SetConnectionStatus(const Value: Boolean);
begin
  //
end;

procedure TModelConexao.SetDescrition(const Value: String);
begin
  FDescrition := Value;
end;

procedure TModelConexao.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TModelConexao.SetReceive(const Value: Boolean);
begin
  FReceive := Value;
end;

procedure TModelConexao.SetSend(const Value: Boolean);
begin
  FSend := Value;
end;

procedure TModelConexao.SetTableReceive(const Value: String);
begin
  FTableReceive := Value;
end;

procedure TModelConexao.SetTableSend(const Value: String);
begin
  FTableSend := Value;
end;

function TModelConexao.StartTransaction: IModelConexao;
begin
  Result := Self;
  FConexao.StartTransaction;
end;

end.
