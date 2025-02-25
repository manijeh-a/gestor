unit Replicador.Controller.Metadata;

interface

uses Replicador.Controller.Interfaces, Replicador.Controller.Tipificacoes,
  System.Classes, IniFiles, Replicador.Model.Metadata.Replicador.Script;

type
  TControllerMetadata = class(TInterfacedObject, IControllerMetadata)
  private
    FLog: TEvLog;
    FMsgLog: String;
    FConexaoLocal: IControllerConexao;
    FInjectBankId: Boolean;
    FMetadataReplicadorScript: iMetadataReplicadorScript;
    FDBVersion: String;
    FVendorLib: String;
    procedure SetConexaoLocal(const Value: IControllerConexao);
    function GetLog: TEvLog;
    function GetMsgLog: String;
    procedure SetLog(const Value: TEvLog);
    procedure SetMsgLog(const Value: String);
    procedure createReplicationGeneretor(I: Integer);
    procedure createReplicationTable(I: Integer; MasterKey: String);
    procedure createReplicationIndex(I: Integer; MasterKey: String);
    procedure createReplicationTriggers(I: Integer; ApplicationName: string;
      MasterKey: string);
    procedure inactiveReplicationTriggers(I: Integer; ApplicationName: String;
      MasterKey: String);
    procedure createKeysMaster(var NewKeys: String; var OldKeys: String;
      MasterKey, Table: string; IdBank: Integer);
    procedure createFieldsMasterReplication(var NewKeys: string;
      MasterKey, Table: string);
    procedure createFieldsTriggerBanks(var NewKeys: string;
      MasterKey, Table: string);
    procedure createReplicationBranch(ApplicationName, MasterKey: String;
      Factor: Integer);
    procedure subMetaVariavel(var Keys: TStringList; Y: Integer; Table: string);
    procedure filterSelectedTables(Tabelas: TStringList; I: Integer);
    procedure GetAllTables(Tabelas: TStringList; I: Integer);
    function VerificaTabela(IdBanco: Integer; Tabela: String;
      Deletar: Boolean = false): Boolean;
    function VerificaGenerator(IdBanco: Integer; Generator: String;
      Deletar: Boolean = false): Boolean;
    function VerificaIndex(IdBanco: Integer; Index: String;
      Deletar: Boolean = false): Boolean;
    procedure CreateProcedureGUUID(IdBanco: Integer);
    function InjectBankId(Value: Boolean): IControllerMetadata;
  public
    constructor Create(Host, Path, TypeDB, DBVersion, User, Password, RoleName,
      Server, Port, VendorLib: String);
    class function New(Host, Path, TypeDB, DBVersion, User, Password, RoleName,
      Server, Port, VendorLib: String): IControllerMetadata;

    procedure removeReplicationStructure;

    // Bancos Replicados
    procedure createReplicationStructure(ApplicationName, MasterKey: String);
    procedure disableReplicationStructure(ApplicationName, MasterKey: String);
    procedure enableReplicationStructure(ApplicationName, MasterKey: String);
    procedure createReplicationBank(MasterKeys: String);
    procedure createReplicationList;
    procedure createFieldsConfig;
    procedure createTablesPriority;

    // Banco do Replicador
    procedure createStructureBank;
    procedure createBankGeneretor;
    procedure createBankTable(MasterKey: String);
    procedure createBankIndex(MasterKey: String);
    procedure createBankTriggers(MasterKey: String);

    // Estrutura MultiFilial
    procedure createBranchGenerator(Factor: Integer);
    procedure createBranchTrigger(ApplicationName, MasterKey: String);

    // Limpar Replicação
    procedure deleteTableIniOrder;
    procedure deleteReplicationGenerator;
    procedure deleteReplicationTrigger;
    procedure deleteReplicationTable;

    property Conexoes: IControllerConexao read FConexaoLocal
      write SetConexaoLocal;
    property Log: TEvLog read GetLog write SetLog;
    property MsgLog: String read GetMsgLog write SetMsgLog;
  end;

implementation

uses
  Replicador.Controller.Factory, System.SysUtils,
  FireDAC.Phys.Intf;

{ TControllerMetadata }

constructor TControllerMetadata.Create(Host, Path, TypeDB, DBVersion, User,
  Password, RoleName, Server, Port, VendorLib: String);
begin
  FDBVersion := DBVersion;
  FVendorLib := VendorLib;
  Conexoes := TControllerFactory.New.Conexao;
  Conexoes.AdicionaConexao(Path, TypeDB, DBVersion, User, Password, RoleName,
    Server, Port, VendorLib, 0, 'Local', '', '', True, True);
  FMetadataReplicadorScript := TModelMetadataReplicadorScript.New
    (Conexoes.ListaConexoes[0]);
end;

procedure TControllerMetadata.createReplicationStructure(ApplicationName,
  MasterKey: String);
var
  I: Integer;
begin
  createReplicationList;
  for I := 1 to Conexoes.ListaConexoes.Count - 1 do
  begin
    CreateProcedureGUUID(I);
    createReplicationGeneretor(I);
    createReplicationTable(I, MasterKey);
    createReplicationIndex(I, MasterKey);
    createReplicationTriggers(I, ApplicationName, MasterKey);
    createFieldsConfig;
    createTablesPriority;
    MsgLog := 'ESTRUTURA CRIADA COM SUCESSO';
  end;
end;

procedure TControllerMetadata.createReplicationBank(MasterKeys: String);
begin
  createStructureBank;
  MsgLog := 'ESTRUTURA CRIADA COM SUCESSO';
end;

procedure TControllerMetadata.createReplicationBranch(ApplicationName,
  MasterKey: String; Factor: Integer);
begin
  createReplicationList;
  // createBranchGenerator(Factor);
  // createBranchTrigger(ApplicationName, Masterkey);
  // MsgLog := 'ESTRUTURA MULTIBRANCH CRIADA COM SUCESSO';
end;

procedure TControllerMetadata.createReplicationGeneretor(I: Integer);
begin
  MsgLog := 'CRIANDO ESTRUTURA DE REPLICAÇÃO NO BANCO: ' +
    Conexoes.ListaConexoes[I].Descrition;
  try
    MsgLog := 'GENERATOR DE REPLICAÇÃO CRIADA COM SUCESSO';
  except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;
end;

procedure TControllerMetadata.createReplicationTable(I: Integer;
  MasterKey: String);
var
  NewKeys: string;
begin
  try
    if not VerificaTabela(I, 'REPLICACAO', false) then
    begin
      createFieldsMasterReplication(NewKeys, MasterKey, '');
      Conexoes.ListaConexoes[I].Query(1)
        .ExecuteSQL('CREATE TABLE REPLICACAO (                  ' +
        '     GUUID         VARCHAR(64) NOT NULL,   ' +
        '     REGISTROS     VARCHAR(1024) NOT NULL,  ' +
        '     TABELA        VARCHAR(255) NOT NULL,   ' +
        '     ACAO          CHAR(1),                 ' +
        '     DATAINCLUSAO  TIMESTAMP NOT NULL       ' + ' );');
      MsgLog := 'TABELA DE REPLICAÇÃO CRIADA COM SUCESSO';
    end;

    Conexoes.ListaConexoes[I].Query(1).ParamCheck(false);
    Conexoes.ListaConexoes[I].Query(1)
      .ExecuteSQL('CREATE OR ALTER TRIGGER REPLICACAO_RPLI0 FOR REPLICACAO ' +
      #13 + ' ACTIVE BEFORE INSERT POSITION 0                        ' + #13 +
      ' AS                                                     ' + #13 +
      ' declare variable UUID  Varchar(32); ' + #13 +
      ' begin                                                  ' + #13 +
      ' execute procedure get_hex_uuid returning_values :UUID; ' + #13 +
      ' New.GUUID = :UUID;                  ' + #13 +
      ' end                                                    ');
    Conexoes.ListaConexoes[I].Query(1).ParamCheck(True);
    MsgLog := 'TRIGGER TABELA DE REPLICAÇÃO CRIADA COM SUCESSO';

  except
    on E: Exception do
      MsgLog := E.Message;
  end;
end;

procedure TControllerMetadata.createReplicationIndex(I: Integer;
  MasterKey: String);
begin
  try
    if not VerificaIndex(I, 'PK_REPLICACAO', false) then
    begin
      Conexoes.ListaConexoes[I].Query(1)
        .ExecuteSQL
        ('ALTER TABLE REPLICACAO ADD CONSTRAINT PK_REPLICACAO PRIMARY KEY (GUUID);');
      MsgLog := 'INDEX DE REPLICAÇÃO CRIADO COM SUCESSO';
    end;
  except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;
end;

procedure TControllerMetadata.createReplicationTriggers(I: Integer;
  ApplicationName: string; MasterKey: string);
var
  Tabelas: TStringList;
  X: Integer;
  NewKeys, OldKeys: String;
  SQL: string;
  InsertKey: string;
  nTabela: String;
  _a: string;
  Ll: TStringList;
begin
  try
    if Conexoes.ListaConexoes[I].Send or Conexoes.ListaConexoes[I].Receive then
    begin
      Tabelas := TStringList.Create;
      filterSelectedTables(Tabelas, I);
      for X := 0 to Tabelas.Count - 1 do
      begin
        NewKeys := '';
        OldKeys := '';
        createKeysMaster(NewKeys, OldKeys, MasterKey, Tabelas[X], I);
        if (Tabelas[X] <> 'REPLICACAO') AND (Tabelas[X] <> 'TABELA') AND
          (Tabelas[X] <> 'VENDAS_TERMINAIS') AND (Tabelas[X] <> 'PEMISSOES') AND
          (Tabelas[X] <> 'USUARIOS') AND (Tabelas[X] <> 'CONFIG') AND
          (Tabelas[X] <> 'CIDADE') AND (Tabelas[X] <> 'CURVA_ABC') AND
          (Tabelas[X] <> 'LOG_DETALHE') AND (Tabelas[X] <> 'LOG_MASTER') AND
          (Tabelas[X] <> 'XMLPRODUTO') AND (Tabelas[X] <> 'XML_DETAIL') AND
          (Tabelas[X] <> 'XML_MASTER') AND (Tabelas[X] <> 'TELAS') AND
          (Tabelas[X] <> 'TRADUTOR') AND (Tabelas[X] <> 'ETIQUETAS') AND
          (Tabelas[X] <> 'ETIQUETA_CAMPOS') AND
          (Tabelas[X] <> 'ETIQUETA_IMPRESSAO') AND (NewKeys <> '') then
        begin
          nTabela := Tabelas[X];

          _a := 'M.MON$REMOTE_PROCESS';
          //
          // if FDBVersion = '3.0' then
          // _a := 'M.MON$USER';

          if Length(nTabela) > 15 then
            nTabela := Copy(nTabela, 1, 18);
          SQL := 'CREATE OR ALTER TRIGGER RPL_' + IntToStr(X) + '_' + nTabela +
            '_REG FOR ' + Tabelas[X] + ' ACTIVE ' + #13 +
            '  AFTER INSERT OR UPDATE OR DELETE POSITION 0      ' + #13 +
            '  AS                                               ' + #13 +
            '   declare variable conexao varchar(1024);            ' + #13 +
            '  begin                                            ' + '  select '
            + _a + ' from MON$ATTACHMENTS M where M.MON$ATTACHMENT_ID = current_connection into :conexao; '
            + #13 + '  if (position(' +
            QuotedStr(ExtractFileName(ApplicationName)) +
            ' in (:conexao)) <= 0) then ' + #13 +
            '     Begin                                           ' + #13 +
            '       if (inserting) then                           ' + #13 +
            '         insert into REPLICACAO (TABELA,REGISTROS,ACAO,DATAINCLUSAO)   '
            + #13 + '              values(' + QuotedStr(Tabelas[X]) + ', ' +
            NewKeys + ',''I'', CURRENT_TIMESTAMP);       ' + #13 +
            '       if (updating) then                            ' + #13 +
            '         insert into REPLICACAO (TABELA,REGISTROS,ACAO,DATAINCLUSAO)   '
            + #13 + '               values(' + QuotedStr(Tabelas[X]) + ', ' +
            NewKeys + ',''U'', CURRENT_TIMESTAMP);       ' + #13 +
            '       if (deleting) then                            ' + #13 +
            '        insert into REPLICACAO (TABELA,REGISTROS,ACAO,DATAINCLUSAO)   '
            + #13 + '               values(' + QuotedStr(Tabelas[X]) + ', ' +
            OldKeys + ',''D'', CURRENT_TIMESTAMP);       ' + #13 +
            '     end                                            ' + #13
            + '  end';
          Conexoes.ListaConexoes[I].Query(1).ParamCheck(false);
          Conexoes.ListaConexoes[I].Query(1).ExecuteSQL(SQL);
          Conexoes.ListaConexoes[I].Query(1).ParamCheck(True);
          MsgLog := 'TRIGGER DA TABELA ' + Tabelas[X] + ' CRIADAS COM SUCESSO';

          if FInjectBankId then
          begin
            try
              SQL := 'ALTER TABLE ' + Tabelas[X] + ' ADD RPL_IDFILIAL SMALLINT';
              Conexoes.ListaConexoes[I].Query(1).ExecuteSQL(SQL);
              MsgLog := 'CAMPO FILIAL NA ' + Tabelas[X] +
                ' CRIADAS COM SUCESSO';
            except
              //
            end;
          end;

        end;
      end;

      // Trigger tabela Replicação
      SQL := ' CREATE OR ALTER TRIGGER REPLICACAO_BI0 FOR REPLICACAO             '
        + #13;
      SQL := SQL +
        ' ACTIVE BEFORE INSERT POSITION 0                                   ' +
        #13;
      SQL := SQL +
        ' AS                                                                ' +
        #13;
      SQL := SQL + ' begin ' + #13;
      SQL := SQL +
        '  IF (exists(SELECT * FROM REPLICACAO WHERE REGISTROS = NEW.REGISTROS AND TABELA = new.tabela AND DATAINCLUSAO = New.datainclusao AND NEW.ACAO = ACAO)) then  '
        + #13;
      SQL := SQL +
        '     DELETE FROM REPLICACAO WHERE REGISTROS = NEW.REGISTROS AND TABELA = new.tabela AND DATAINCLUSAO = New.datainclusao AND NEW.ACAO = ACAO; '
        + #13;
      SQL := SQL + ' end;';
      Conexoes.ListaConexoes[I].Query(1).ParamCheck(false);
      Conexoes.ListaConexoes[I].Query(1).ExecuteSQL(SQL);
      Conexoes.ListaConexoes[I].Query(1).ParamCheck(True);
    end;
  except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;
end;

procedure TControllerMetadata.createStructureBank;
begin
  createBankGeneretor;
  createBankTable('');
  createBankIndex('');
  createBankTriggers('');
  FMetadataReplicadorScript.Executar;
end;

procedure TControllerMetadata.deleteReplicationGenerator;
var
  I: Integer;
  aSQL: string;
begin
  for I := 1 to Conexoes.ListaConexoes.Count - 1 do
  begin
    Conexoes.ListaConexoes[I].Query(2)
      .OpenSQL('SELECT RDB$GENERATOR_NAME AS NAME FROM RDB$GENERATORS  WHERE RDB$GENERATOR_NAME LIKE '
      + QuotedStr('GEN_REPLICACAO%'));
    while not Conexoes.ListaConexoes[I].Query(2).DataSet.Eof do
    begin
      try
        aSQL := 'DROP SEQUENCE ' + Conexoes.ListaConexoes[I].Query(2)
          .DataSet.FieldByName('NAME').AsString + ';';
        Conexoes.ListaConexoes[I].Query(1).ExecuteSQL(aSQL);
        MsgLog := 'GENERATOR ' + Conexoes.ListaConexoes[I].Query(2)
          .DataSet.FieldByName('NAME').AsString + ' REMOVIDA COM SUCESSO';
        Conexoes.ListaConexoes[I].Query(2).DataSet.Next;
      Except
        on E: Exception do
          MsgLog := 'ERROR: ' + E.Message;
      end;
    end;
  end;
end;

procedure TControllerMetadata.deleteReplicationTable;
var
  I: Integer;
  aSQL: string;
begin
  for I := 1 to Conexoes.ListaConexoes.Count - 1 do
  begin
    try
      Conexoes.ListaConexoes[I].Query(2)
        .OpenSQL('  SELECT 1 AS EXISTE FROM RDB$RELATIONS ' +
        '  WHERE RDB$FLAGS=1 and RDB$RELATION_NAME=' + QuotedStr('REPLICACAO'));
      if Conexoes.ListaConexoes[I].Query(2).DataSet.FieldByName('EXISTE')
        .AsInteger >= 1 then
      begin
        aSQL := 'DROP TABLE REPLICACAO;';
        Conexoes.ListaConexoes[I].Query(1).ExecuteSQL(aSQL);
        MsgLog := 'TABELA DE REPLICAÇÃO REMOVIDA COM SUCESSO';
      end;
    Except
      on E: Exception do
        MsgLog := 'ERROR: ' + E.Message;
    end;
  end;
end;

procedure TControllerMetadata.CreateProcedureGUUID(IdBanco: Integer);
var
  SQL: String;
begin
  try
    SQL := '';
    SQL := SQL + ' create or alter procedure get_hex_uuid ' + ''#13'';
    SQL := SQL + ' returns(hex_uuid varchar(32)) ' + ''#13'';
    SQL := SQL + ' AS ' + ''#13'';
    SQL := SQL + ' declare variable i integer; ' + ''#13'';
    SQL := SQL + ' declare variable c integer; ' + ''#13'';
    SQL := SQL + ' declare variable real_uuid char(16) character set OCTETS; '
      + ''#13'';
    SQL := SQL + ' BEGIN ' + ''#13'';
    SQL := SQL + ' real_uuid = GEN_UUID(); ' + ''#13'';
    SQL := SQL + ' hex_uuid = ''''; ' + ''#13'';
    SQL := SQL + ' i = 0; ' + ''#13'';
    SQL := SQL + ' while (i < 16) do ' + ''#13'';
    SQL := SQL + ' begin ' + ''#13'';
    SQL := SQL + ' c = ascii_val(substring(real_uuid from i+1 for 1)); '
      + ''#13'';
    SQL := SQL + ' if (c < 0) then c = 256 + c; ' + ''#13'';
    SQL := SQL + ' hex_uuid = hex_uuid ' + ''#13'';
    SQL := SQL +
      ' || substring(''0123456789abcdef'' from bin_shr(c, 4) + 1 for 1) '
      + ''#13'';
    SQL := SQL +
      ' || substring(''0123456789abcdef'' from bin_and(c, 15) + 1 for 1); '
      + ''#13'';
    SQL := SQL + ' i = i + 1; ' + ''#13'';
    SQL := SQL + ' end ' + ''#13'';
    SQL := SQL + ' suspend; ';
    SQL := SQL + ' END; ';
    Conexoes.ListaConexoes[IdBanco].Query(1).ParamCheck(false);
    Conexoes.ListaConexoes[IdBanco].Query(1).ExecuteSQL(SQL);
    Conexoes.ListaConexoes[IdBanco].Query(1).ParamCheck(True);
  Except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;

end;

function TControllerMetadata.VerificaGenerator(IdBanco: Integer;
  Generator: String; Deletar: Boolean = false): Boolean;
begin
  Result := false;
  Conexoes.ListaConexoes[IdBanco].Query(1)
    .OpenSQL('SELECT 1 AS EXISTE FROM rdb$database WHERE EXISTS(SELECT rdb$generator_name from rdb$generators where rdb$generator_name = '
    + QuotedStr(Generator) + ')');
  if Conexoes.ListaConexoes[IdBanco].Query(1).DataSet.FieldByName('EXISTE')
    .AsInteger >= 1 then
  begin
    Result := True;
    if Deletar then
    begin
      Conexoes.ListaConexoes[IdBanco].Query(1)
        .ExecuteSQL('DROP GENERATOR ' + Generator);
      Result := false;
    end;
  end;
end;

function TControllerMetadata.VerificaIndex(IdBanco: Integer; Index: String;
  Deletar: Boolean = false): Boolean;
begin
  Result := false;
  Conexoes.ListaConexoes[IdBanco].Query(1)
    .OpenSQL('SELECT 1 AS EXISTE FROM rdb$database WHERE EXISTS(SELECT * FROM RDB$INDICES WHERE RDB$INDEX_NAME = '
    + QuotedStr(Index) + ')');
  if Conexoes.ListaConexoes[IdBanco].Query(1).DataSet.FieldByName('EXISTE')
    .AsInteger >= 1 then
  begin
    Result := True;
    if Deletar then
    begin
      Conexoes.ListaConexoes[IdBanco].Query(1)
        .ExecuteSQL('DROP INDEX ' + Index);
      Result := false;
    end;
  end;
end;

function TControllerMetadata.VerificaTabela(IdBanco: Integer; Tabela: String;
  Deletar: Boolean = false): Boolean;
var
  SQL: string;
begin
  Result := false;
  SQL := '';
  SQL := SQL + ' SELECT COUNT(*) QTDE ';
  SQL := SQL + ' FROM RDB$RELATIONS ';
  SQL := SQL + ' WHERE RDB$FLAGS=1 and RDB$RELATION_NAME=' + QuotedStr(Tabela);
  Conexoes.ListaConexoes[IdBanco].Query(1).OpenSQL(SQL);
  if Conexoes.ListaConexoes[IdBanco].Query(1).DataSet.FieldByName('QTDE')
    .AsInteger > 0 then
  begin
    Result := True;
    if Deletar then
    begin
      Conexoes.ListaConexoes[IdBanco].Query(1)
        .ExecuteSQL('DROP TABLE ' + Tabela);
      Result := false;
    end;
  end;
end;

procedure TControllerMetadata.filterSelectedTables(Tabelas: TStringList;
  I: Integer);
var
  aSQL: string;
  aCampo_Chave: String;
begin
  Conexoes.ListaConexoes[0].Query(2)
    .OpenSQL('SELECT TABELASENVIA FROM BANCOS WHERE ID = ' +
    IntToStr(Conexoes.ListaConexoes[I].ID));
  if Trim(Conexoes.ListaConexoes[0].Query(2).DataSet.FieldByName('TABELASENVIA')
    .AsString) <> '' then
  begin
    Tabelas.CommaText := UpperCase(Conexoes.ListaConexoes[0].Query(2)
      .DataSet.FieldByName('TABELASENVIA').AsString);
  end
  else
  begin
    aSQL := 'select rdb$relation_name as tabela from rdb$relations where rdb$system_flag = 0';
    Conexoes.ListaConexoes[I].Query(2).OpenSQL(aSQL);
    while not Conexoes.ListaConexoes[I].Query(2).DataSet.Eof do
    begin
      Tabelas.Add(UpperCase(Conexoes.ListaConexoes[I].Query(2)
        .DataSet.FieldByName('tabela').AsString));
      Conexoes.ListaConexoes[I].Query(2).DataSet.Next;
    end;
  end;
end;

procedure TControllerMetadata.deleteReplicationTrigger;
var
  I: Integer;
  aSQL: string;
begin
  for I := 1 to Conexoes.ListaConexoes.Count - 1 do
  begin
    Conexoes.ListaConexoes[I].Query(2)
      .OpenSQL('select rdb$trigger_name as NAME from rdb$triggers where rdb$trigger_name like '
      + QuotedStr('RPL_%'));
    while not Conexoes.ListaConexoes[I].Query(2).DataSet.Eof do
    begin
      try
        aSQL := 'DROP TRIGGER ' + Conexoes.ListaConexoes[I].Query(2)
          .DataSet.FieldByName('NAME').AsString + ';';
        Conexoes.ListaConexoes[I].Query(1).ExecuteSQL(aSQL);
        MsgLog := 'TRIGGER ' + Conexoes.ListaConexoes[I].Query(2)
          .DataSet.FieldByName('NAME').AsString + ' REMOVIDA COM SUCESSO';
        Conexoes.ListaConexoes[I].Query(2).DataSet.Next;
      Except
        on E: Exception do
          MsgLog := 'ERROR: ' + E.Message;
      end;
    end;
  end;
end;

procedure TControllerMetadata.deleteTableIniOrder;
begin
  if FileExists(ExtractFilePath(ParamStr(0)) + 'TABLE_INSERT_ORDER.ini') then
    DeleteFile(ExtractFilePath(ParamStr(0)) + 'TABLE_INSERT_ORDER.ini');

  if FileExists(ExtractFilePath(ParamStr(0)) + 'TABLE_DELETE_ORDER.ini') then
    DeleteFile(ExtractFilePath(ParamStr(0)) + 'TABLE_DELETE_ORDER.ini')

end;

procedure TControllerMetadata.disableReplicationStructure(ApplicationName,
  MasterKey: String);
var
  I: Integer;
begin
  createReplicationList;
  MsgLog := 'AGUARDE... DESABILITANDO ESTRUTURA DE REPLICAÇÃO';
  for I := 1 to Conexoes.ListaConexoes.Count - 1 do
  begin
    inactiveReplicationTriggers(I, ApplicationName, MasterKey);
  end;
  MsgLog := 'ESTRUTURA DE REPLICAÇÃO DESABILITADA';
end;

procedure TControllerMetadata.enableReplicationStructure(ApplicationName,
  MasterKey: String);
var
  I: Integer;
begin
  createReplicationList;
  MsgLog := 'AGUARDE... HABILITANDO ESTRUTURA DE REPLICAÇÃO';
  for I := 1 to Conexoes.ListaConexoes.Count - 1 do
  begin
    createReplicationTriggers(I, ApplicationName, MasterKey);
  end;
  MsgLog := 'ESTRUTURA DE REPLICAÇÃO HABILITADA';
end;

procedure TControllerMetadata.createBranchTrigger(ApplicationName,
  MasterKey: String);
var
  Tabelas: TStringList;
  I, X: Integer;
  SQL: String;
  aSQL: string;
  aPK: string;
  aName: string;
  Ini: TIniFile;
begin
  for I := 1 to Conexoes.ListaConexoes.Count - 1 do
  begin
    try
      Tabelas := TStringList.Create;
      filterSelectedTables(Tabelas, I);
      for X := 0 to Tabelas.Count - 1 do
      begin
        if (Tabelas[X] <> 'REPLICACAO') AND (Tabelas[X] <> 'TABELA') AND
          (Tabelas[X] <> 'VENDAS_TERMINAIS') AND (Tabelas[X] <> 'PEMISSOES') AND
          (Tabelas[X] <> 'USUARIOS') AND (Tabelas[X] <> 'CONFIG') AND
          (Tabelas[X] <> 'CIDADE') AND (Tabelas[X] <> 'CURVA_ABC') AND
          (Tabelas[X] <> 'LOG_DETALHE') AND (Tabelas[X] <> 'LOG_MASTER') AND
          (Tabelas[X] <> 'XMLPRODUTO') AND (Tabelas[X] <> 'XML_DETAIL') AND
          (Tabelas[X] <> 'XML_MASTER') AND (Tabelas[X] <> 'TELAS') AND
          (Tabelas[X] <> 'TRADUTOR') AND (Tabelas[X] <> 'ETIQUETAS') AND
          (Tabelas[X] <> 'ETIQUETA_CAMPOS') AND
          (Tabelas[X] <> 'ETIQUETA_IMPRESSAO') then
        begin

          aSQL := 'select                                                                           '
            + '     s.rdb$field_name AS PK,                                                     '
            + '     i.rdb$relation_name as TABELA                                               '
            + ' from                                                                            '
            + '     rdb$indices i                                                               '
            + ' left join rdb$index_segments s on i.rdb$index_name = s.rdb$index_name           '
            + ' left join rdb$relation_constraints rc on rc.rdb$index_name = i.rdb$index_name   '
            + ' where                                                                           '
            + '     rc.rdb$constraint_type = ''PRIMARY KEY'' AND ' +
            '     i.rdb$relation_name = ' + QuotedStr(Tabelas[X]) +
            '                              ';

          Conexoes.ListaConexoes[I].Query(2).OpenSQL(aSQL);
          while not Conexoes.ListaConexoes[I].Query(2).DataSet.Eof do
          begin
            aPK := Conexoes.ListaConexoes[I].Query(2)
              .DataSet.FieldByName('PK').AsString;
            aName := Copy(Tabelas[X] + '_' + aPK, 1, 17);
            SQL := '  CREATE OR ALTER TRIGGER RPL_FTR_' + IntToStr(X) + '_' +
              aName + ' FOR ' + Tabelas[X] + '                        ' +
              '  ACTIVE BEFORE INSERT POSITION 99                                                               '
              + '  as                                                                                             '
              + '  declare variable conexao varchar(1024);            ' +
              '  begin                                                                                          '
              + '  select M.MON$REMOTE_PROCESS from MON$ATTACHMENTS M where M.MON$ATTACHMENT_ID = current_connection into :conexao; '
              + '  if (position(' + QuotedStr(ExtractFileName(ApplicationName))
              + ' in (:conexao)) <= 0) then ' +
              '        Begin                                                                                                  '
              + '         new.' + aPK + ' = (cast(new.' + aPK +
              ' as Integer) * GEN_ID(gen_replicacao_fator, 0) ) + GEN_ID(gen_replicacao_id, 0);         '
              + '        END                                                                                                    '
              + '  end; ';
            Conexoes.ListaConexoes[I].Query(1).ExecuteSQL(SQL);
            Conexoes.ListaConexoes[I].Query(2).DataSet.Next;
          end;

          MsgLog := 'TRIGGER DA TABELA ' + Tabelas[X] + ' CRIADAS COM SUCESSO';
        end;
      end;
    except
      on E: Exception do
        MsgLog := 'ERROR: ' + E.Message;
    end;
  end;

end;

procedure TControllerMetadata.subMetaVariavel(var Keys: TStringList; Y: Integer;
  Table: string);
begin
  if Pos('%TABLE%', UpperCase(Keys[Y])) > 0 then
    Keys[Y] := stringreplace(UpperCase(Keys[Y]), '%TABLE%', Table,
      [rfReplaceAll, rfIgnoreCase]);
end;

procedure TControllerMetadata.GetAllTables(Tabelas: TStringList; I: Integer);
var
  aSQL: string;
begin
  aSQL := 'select rdb$relation_name as tabela from rdb$relations where rdb$system_flag = 0';
  Conexoes.ListaConexoes[I].Query(2).OpenSQL(aSQL);
  while not Conexoes.ListaConexoes[I].Query(2).DataSet.Eof do
  begin
    Tabelas.Add(Conexoes.ListaConexoes[I].Query(2).DataSet.FieldByName('tabela')
      .AsString);
    Conexoes.ListaConexoes[I].Query(2).DataSet.Next;
  end;
end;

function TControllerMetadata.GetLog: TEvLog;
begin
  Result := FLog;
end;

function TControllerMetadata.GetMsgLog: String;
begin
  Result := FMsgLog;
end;

procedure TControllerMetadata.inactiveReplicationTriggers(I: Integer;
  ApplicationName, MasterKey: String);
var
  Tabelas: TStringList;
  X: Integer;
  NewKeys, OldKeys: String;
  SQL: string;
  InsertKey: string;
  nTabela: String;
begin
  try
    if Conexoes.ListaConexoes[I].Send or Conexoes.ListaConexoes[I].Receive then
    begin
      Tabelas := TStringList.Create;
      filterSelectedTables(Tabelas, I);
      for X := 0 to Tabelas.Count - 1 do
      begin

        NewKeys := '';
        OldKeys := '';
        createKeysMaster(NewKeys, OldKeys, MasterKey, Tabelas[X], I);
        if (Tabelas[X] <> 'REPLICACAO') AND (Tabelas[X] <> 'TABELA') AND
          (Tabelas[X] <> 'VENDAS_TERMINAIS') AND (Tabelas[X] <> 'PEMISSOES') AND
          (Tabelas[X] <> 'USUARIOS') AND (Tabelas[X] <> 'CONFIG') AND
          (Tabelas[X] <> 'CIDADE') AND (Tabelas[X] <> 'CURVA_ABC') AND
          (Tabelas[X] <> 'LOG_DETALHE') AND (Tabelas[X] <> 'LOG_MASTER') AND
          (Tabelas[X] <> 'XMLPRODUTO') AND (Tabelas[X] <> 'XML_DETAIL') AND
          (Tabelas[X] <> 'XML_MASTER') AND (Tabelas[X] <> 'TELAS') AND
          (Tabelas[X] <> 'TRADUTOR') AND (Tabelas[X] <> 'ETIQUETAS') AND
          (Tabelas[X] <> 'ETIQUETA_CAMPOS') AND
          (Tabelas[X] <> 'ETIQUETA_IMPRESSAO') AND (NewKeys <> '') then
        begin
          nTabela := Tabelas[X];
          if Length(nTabela) > 15 then
            nTabela := Copy(nTabela, 1, 23);
          SQL := 'CREATE OR ALTER TRIGGER RPL_' + nTabela + '_REG FOR ' +
            Tabelas[X] + ' inactive ' +
            '  AFTER INSERT OR UPDATE OR DELETE POSITION 0      ' +
            '  AS                                               ' +
            '  declare variable conexao varchar(1024);            ' +
            '  begin                                            ' +
            '  select M.MON$REMOTE_PROCESS from MON$ATTACHMENTS M where M.MON$ATTACHMENT_ID = current_connection into :conexao; '
            + '  if (position(' + QuotedStr(ExtractFileName(ApplicationName)) +
            ' in (:conexao)) <= 0) then ' +
            '     Begin                                           ' +
            '       if (inserting) then                           ' +
            '         insert into REPLICACAO (TABELA,REGISTROS,ACAO,DATAINCLUSAO)   '
            + '              values(' + QuotedStr(Tabelas[X]) + ', ' + NewKeys +
            ',''I'', CURRENT_TIMESTAMP);       ' +
            '       if (updating) then                            ' +
            '         insert into REPLICACAO (TABELA,REGISTROS,ACAO,DATAINCLUSAO)   '
            + '               values(' + QuotedStr(Tabelas[X]) + ', ' + NewKeys
            + ',''U'', CURRENT_TIMESTAMP);       ' +
            '       if (deleting) then                            ' +
            '        insert into REPLICACAO (TABELA,REGISTROS,ACAO,DATAINCLUSAO)   '
            + '               values(' + QuotedStr(Tabelas[X]) + ', ' + OldKeys
            + ',''D'', CURRENT_TIMESTAMP);       ' +
            '     end                                            ' + '  end;';
          Conexoes.ListaConexoes[I].Query(1).ExecuteSQL(SQL);
          MsgLog := 'TRIGGER DA TABELA ' + Tabelas[X] + ' CRIADAS COM SUCESSO';
        end;
      end;
      // Trigger tabela Replicação
      SQL := ' CREATE OR ALTER TRIGGER REPLICACAO_BI0 FOR REPLICACAO             '
        + ' inactive BEFORE INSERT POSITION 0                                   '
        + ' AS                                                                '
        + ' begin                                                             '
        + '  IF (exists(SELECT * FROM REPLICACAO WHERE REGISTROS = NEW.REGISTROS AND TABELA = new.tabela AND DATAINCLUSAO = New.datainclusao AND NEW.ACAO = ACAO)) then  '
        + '     DELETE FROM REPLICACAO WHERE REGISTROS = NEW.REGISTROS AND TABELA = new.tabela AND DATAINCLUSAO = New.datainclusao AND NEW.ACAO = ACAO; '
        + ' end;';
      Conexoes.ListaConexoes[I].Query(1).ExecuteSQL(SQL);
    end;
  except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;
end;

function TControllerMetadata.InjectBankId(Value: Boolean): IControllerMetadata;
begin
  Result := Self;
  FInjectBankId := Value;
end;

procedure TControllerMetadata.createReplicationList;
var
  Enviar: Boolean;
  Receber: Boolean;
begin
  Conexoes.ListaConexoes[0].Query(1).OpenSQL('SELECT * FROM BANCOS');
  with Conexoes.ListaConexoes[0].Query(1).DataSet do
  begin
    while not Eof do
    begin
      Enviar := false;
      Receber := false;
      if FieldByName('ENVIAR').AsInteger = 1 then
        Enviar := True;
      if FieldByName('RECEBER').AsInteger = 1 then
        Receber := True;
      Conexoes.AdicionaConexao(FieldByName('PATH').AsString, 'FB', FDBVersion,
        FieldByName('USUARIO').AsString, FieldByName('SENHA').AsString,
        FieldByName('ROLE').AsString, FieldByName('HOST').AsString,
        FieldByName('PORT').AsString, FVendorLib, FieldByName('ID').AsInteger,
        FieldByName('DESCRICAO').AsString, FieldByName('TABELASENVIA').AsString,
        FieldByName('TABELASRECEBE').AsString, Enviar, Receber);
      Next;
    end;
  end;
end;

procedure TControllerMetadata.createBankGeneretor;
begin
  try
    if not VerificaGenerator(0, 'GEN_BANCOS_ID', false) then
      Conexoes.ListaConexoes[0].Query(1)
        .ExecuteSQL('CREATE GENERATOR GEN_BANCOS_ID;');
    MsgLog := 'GENERATORS CRIADAS COM SUCESSO';
  except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;
end;

procedure TControllerMetadata.createBankIndex(MasterKey: String);
begin
  try
    try
      if not VerificaIndex(0, 'PK_BANCOS PRIMARY', false) then
        Conexoes.ListaConexoes[0].Query(1)
          .ExecuteSQL
          ('ALTER TABLE BANCOS ADD CONSTRAINT PK_BANCOS PRIMARY KEY (ID);');
    except
      // on E: Exception do
      // MsgLog := 'ERROR: ' + E.Message;
    end;

    try
      if not VerificaIndex(0, 'PK_REPLICACAO', false) then
        Conexoes.ListaConexoes[0].Query(1)
          .ExecuteSQL
          ('ALTER TABLE REPLICACAO ADD CONSTRAINT PK_REPLICACAO PRIMARY KEY (GUUID);');
    except
      on E: Exception do
        MsgLog := 'ERROR: ' + E.Message;
    end;
  finally
    MsgLog := 'INDEX CRIADOS COM SUCESSO';
  end;
end;

procedure TControllerMetadata.createBankTable(MasterKey: String);
var
  NewKeys: string;
begin
  try
    if not VerificaTabela(0, 'BANCOS', false) then
    begin
      Conexoes.ListaConexoes[0].Query(1)
        .ExecuteSQL('  CREATE TABLE BANCOS (                  ' +
        '  ID             INTEGER NOT NULL,       ' +
        '  DESCRICAO      VARCHAR(60),            ' +
        '  HOST           VARCHAR(60),            ' +
        '  PATH           VARCHAR(255),           ' +
        '  USUARIO        VARCHAR(60),            ' +
        '  SENHA          VARCHAR(60),            ' +
        '  ROLE           VARCHAR(60),            ' +
        '  PORT           INTEGER,                ' +
        '  ENVIAR         INTEGER,                ' +
        '  RECEBER        INTEGER,                ' +
        '  PRIORIDADE     SMALLINT,               ' +
        '  TABELASENVIA   VARCHAR(4096),          ' +
        '  TABELASRECEBE  VARCHAR(4096)           ' + ' );');
    end;

    if not VerificaTabela(0, 'REPLICACAO', false) then
    begin
      Conexoes.ListaConexoes[0].Query(1)
        .ExecuteSQL('  CREATE TABLE REPLICACAO (              ' +
        '  IDBANCO       INTEGER NOT NULL,        ' +
        '  IDRECEIVER    INTEGER NOT NULL,        ' +
        '  REGISTROS     VARCHAR(1024) NOT NULL,   ' +
        '  TABELA        VARCHAR(60) NOT NULL,    ' +
        '  ACAO          CHAR(1),                 ' +
        '  DATAINCLUSAO  TIMESTAMP NOT NULL,      ' +
        '  GUUID         VARCHAR(256) NOT NULL     ' + '  ); ');
    end;

    if not VerificaGenerator(0, 'GEN_REPLICACOES_ID', false) then
      Conexoes.ListaConexoes[0].Query(1)
        .ExecuteSQL('CREATE GENERATOR GEN_REPLICACOES_ID;');

    MsgLog := 'TABELAS CRIADAS COM SUCESSO';
  except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;
end;

procedure TControllerMetadata.createBankTriggers(MasterKey: String);
var
  NewKeys: string;
  SQL: string;
  Lista: TStringList;
begin
  try
    CreateProcedureGUUID(0);

    Conexoes.ListaConexoes[0].Query(1)
      .ExecuteSQL('  CREATE OR ALTER TRIGGER BANCOS_BI FOR BANCOS       ' +
      '  ACTIVE BEFORE INSERT POSITION 0           ' +
      '  as                                        ' +
      '  begin                                     ' +
      '    if (new.id is null) then                ' +
      '      new.id = gen_id(gen_bancos_id,1);     ' +
      '  end;                                       ');

  except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;

  try
    SQL := '';
    SQL := SQL +
      ' CREATE OR ALTER TRIGGER REPLICACOES_BI0 FOR REPLICACAO ' + #13;
    SQL := SQL + ' ACTIVE BEFORE INSERT POSITION 0 ' + #13;
    SQL := SQL + ' AS ' + #13;
    SQL := SQL + ' declare variable xID Integer; ' + #13;
    SQL := SQL + ' declare variable UUID  Varchar(32); ' + #13;
    SQL := SQL + ' begin ' + #13;
    SQL := SQL +
      ' execute procedure get_hex_uuid returning_values :UUID; ' + #13;
    SQL := SQL + ' New.GUUID = :UUID; ' + #13;
    SQL := SQL +
      ' if (exists(SELECT * FROM REPLICACAO WHERE REGISTROS = NEW.REGISTROS AND TABELA = new.tabela AND (DATAINCLUSAO < New.datainclusao) AND NEW.IDBANCO = IDBANCO)) then '
      + #13;
    SQL := SQL +
      ' delete from REPLICACAO WHERE REGISTROS = NEW.REGISTROS AND TABELA = new.tabela AND (DATAINCLUSAO < New.datainclusao); '
      + #13;
    SQL := SQL + ' if (New.idreceiver = 0) then ' + #13;
    SQL := SQL + ' begin ' + #13;
    SQL := SQL +
      ' FOR SELECT ID FROM BANCOS WHERE ID <> NEW.IDBANCO AND RECEBER = 1 into :xID do '
      + #13;
    SQL := SQL + ' BEGIN ' + #13;
    SQL := SQL +
      ' INSERT INTO replicacao (IDBANCO, IDRECEIVER, REGISTROS, TABELA, ACAO, DATAINCLUSAO) VALUES (New.idbanco, :xID, NEw.REGISTROS, New.tabela,  New.ACAO, New.DATAINCLUSAO); '
      + #13;
    SQL := SQL + ' END ' + #13;
    SQL := SQL + ' end ' + #13;
    SQL := SQL + ' end; ';
    Conexoes.ListaConexoes[0].Query(1).ParamCheck(false);
    Conexoes.ListaConexoes[0].Query(1).ExecuteSQL(SQL);
    Conexoes.ListaConexoes[0].Query(1).ParamCheck(True);

  except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;

  MsgLog := 'GENERATORS CRIADAS';

end;

procedure TControllerMetadata.createFieldsConfig;
var
  Tabelas: TStringList;
  X: Integer;
  I: Integer;
  Ini: TIniFile;
begin
  if not FileExists(ExtractFilePath(ParamStr(0)) + 'FIELDS.ini') then
  begin
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'FIELDS.ini');
    try
      for I := 1 to Conexoes.ListaConexoes.Count - 1 do
      begin
        Tabelas := TStringList.Create;
        try
          Tabelas.CommaText := Conexoes.ListaConexoes[I].TableSend;
          for X := 0 to Tabelas.Count - 1 do
            Ini.WriteString(Conexoes.ListaConexoes[I].Descrition,
              Tabelas[X], '*');
        finally
          Tabelas.Free;
        end;
      end;
    finally
      Ini.Free;
    end;
  end;
end;

procedure TControllerMetadata.createTablesPriority;
var
  Tabelas: TStringList;
  X: Integer;
  I: Integer;
  Ini: TIniFile;
  aSQL: String;
begin

  if not FileExists(ExtractFilePath(ParamStr(0)) + 'TABLE_INSERT_ORDER.ini')
  then
  begin
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) +
      'TABLE_INSERT_ORDER.ini');
    try
      for I := 1 to Conexoes.ListaConexoes.Count - 1 do
      begin
        try
          X := 0;
          aSQL := 'select rdb$relation_name as tabela from rdb$relations where rdb$system_flag = 0';
          Conexoes.ListaConexoes[I].Query(2).OpenSQL(aSQL);
          while not Conexoes.ListaConexoes[I].Query(2).DataSet.Eof do
          begin
            Ini.WriteString(Conexoes.ListaConexoes[I].Descrition, IntToStr(X),
              Conexoes.ListaConexoes[I].Query(2).DataSet.FieldByName('TABELA')
              .AsString);
            Conexoes.ListaConexoes[I].Query(2).DataSet.Next;
            Inc(X);
          end;
        finally
          Tabelas.Free;
        end;
      end;
    finally
      Ini.Free;
    end;
  end;

  if not FileExists(ExtractFilePath(ParamStr(0)) + 'TABLE_DELETE_ORDER.ini')
  then
  begin
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) +
      'TABLE_DELETE_ORDER.ini');
    try
      for I := 1 to Conexoes.ListaConexoes.Count - 1 do
      begin
        try
          X := 0;
          aSQL := 'select rdb$relation_name as tabela from rdb$relations where rdb$system_flag = 0';
          Conexoes.ListaConexoes[I].Query(2).OpenSQL(aSQL);
          while not Conexoes.ListaConexoes[I].Query(2).DataSet.Eof do
          begin
            Ini.WriteString(Conexoes.ListaConexoes[I].Descrition, IntToStr(X),
              Conexoes.ListaConexoes[I].Query(2).DataSet.FieldByName('TABELA')
              .AsString);
            Conexoes.ListaConexoes[I].Query(2).DataSet.Next;
            Inc(X);
          end;
        finally
          Tabelas.Free;
        end;
      end;
    finally
      Ini.Free;
    end;
  end;
end;

procedure TControllerMetadata.createFieldsMasterReplication(var NewKeys: string;
  MasterKey, Table: string);
var
  Keys: TStringList;
  AuxKey: string;
  Y: Integer;
begin
  Keys := TStringList.Create;
  try
    if Pos('%TABLE%', UpperCase(MasterKey)) > 0 then
      MasterKey := stringreplace(UpperCase(MasterKey), '%TABLE%', '',
        [rfReplaceAll, rfIgnoreCase]);
    Keys.CommaText := MasterKey;
    begin
      AuxKey := ',';
      for Y := 0 to Keys.Count - 1 do
      begin
        NewKeys := NewKeys + Keys[Y] + ' INTEGER NOT NULL' + AuxKey;
      end;
    end;
  finally
    Keys.Free;
  end;
end;

procedure TControllerMetadata.createFieldsTriggerBanks(var NewKeys: string;
  MasterKey, Table: string);
var
  Keys: TStringList;
  AuxKey: string;
  Y: Integer;
  SQL: string;
begin
  Keys := TStringList.Create;
  try
    if Pos('%TABLE%', UpperCase(MasterKey)) > 0 then
      MasterKey := stringreplace(UpperCase(MasterKey), '%TABLE%', '',
        [rfReplaceAll, rfIgnoreCase]);
    Keys.CommaText := MasterKey;
    begin
      AuxKey := ' AND ';
      for Y := 0 to Keys.Count - 1 do
      begin
        NewKeys := NewKeys + Keys[Y] + ' = NEW.' + Keys[Y] + AuxKey;
      end;
    end;
  finally
    Keys.Free;
  end;
end;

procedure TControllerMetadata.createKeysMaster(var NewKeys: String;
  var OldKeys: String; MasterKey, Table: string; IdBank: Integer);
var
  Keys: TStringList;
  AuxKey: string;
  Y: Integer;
  SQL: string;
  aPK: string;
  I: Integer;
begin
  SQL := 'select                                                                        '
    + '     s.rdb$field_name AS PK,                                                     '
    + '     i.rdb$relation_name as TABELA                                               '
    + ' from                                                                            '
    + '     rdb$indices i                                                               '
    + ' left join rdb$index_segments s on i.rdb$index_name = s.rdb$index_name           '
    + ' left join rdb$relation_constraints rc on rc.rdb$index_name = i.rdb$index_name   '
    + ' where                                                                           '
    + '     rc.rdb$constraint_type = ''PRIMARY KEY'' AND                                '
    + '     i.rdb$relation_name = ' + QuotedStr(Table) +
    '                              ';

  AuxKey := QuotedStr(' AND ') + '||';
  Conexoes.ListaConexoes[IdBank].Query(2).OpenSQL(SQL);
  for I := 0 to Conexoes.ListaConexoes[IdBank].Query(2)
    .DataSet.RecordCount - 1 do
  begin
    if I = Conexoes.ListaConexoes[IdBank].Query(2).DataSet.RecordCount - 1 then
      AuxKey := QuotedStr('');
    aPK := 'GID';
    // Conexoes.ListaConexoes[IdBank].Query(2).DataSet.FieldByName('PK').AsString;

    NewKeys := NewKeys + QuotedStr(aPK + ' = ') + QuotedStr('') +
      ' || Replace(New.' + aPK + ', ' + QuotedStr('''') + ', ' + QuotedStr('"')
      + ') || ' + QuotedStr('') + AuxKey;
    OldKeys := OldKeys + QuotedStr(aPK + ' = ') + QuotedStr('') +
      ' || Replace(Old.' + aPK + ', ' + QuotedStr('''') + ', ' + QuotedStr('"')
      + ') || ' + QuotedStr('') + AuxKey;
    Conexoes.ListaConexoes[IdBank].Query(2).DataSet.Next;
  end;
end;

procedure TControllerMetadata.createBranchGenerator(Factor: Integer);
var
  I: Integer;
begin
  try
    for I := 1 to Conexoes.ListaConexoes.Count - 1 do
    begin
      Conexoes.ListaConexoes[I].Query(1)
        .ExecuteSQL('CREATE GENERATOR GEN_REPLICACAO_FATOR;');
      Conexoes.ListaConexoes[I].Query(1)
        .ExecuteSQL('CREATE GENERATOR GEN_REPLICACAO_ID;');
      Conexoes.ListaConexoes[I].Query(1)
        .ExecuteSQL('ALTER SEQUENCE GEN_REPLICACAO_ID RESTART WITH ' +
        IntToStr(Conexoes.ListaConexoes[I].ID));
      Conexoes.ListaConexoes[I].Query(1)
        .ExecuteSQL('ALTER SEQUENCE GEN_REPLICACAO_FATOR RESTART WITH ' +
        IntToStr(Factor));
    end;
    MsgLog := 'GENERATORS CRIADAS COM SUCESSO';
  except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;
end;

class function TControllerMetadata.New(Host, Path, TypeDB, DBVersion, User,
  Password, RoleName, Server, Port, VendorLib: String): IControllerMetadata;
begin
  Result := TControllerMetadata.Create(Host, Path, TypeDB, DBVersion, User,
    Password, RoleName, Server, Port, VendorLib);
end;

procedure TControllerMetadata.removeReplicationStructure;
begin
  try
    createReplicationList;
    deleteReplicationTrigger;
    deleteReplicationGenerator;
    deleteReplicationTable;
    deleteTableIniOrder;
    MsgLog := 'ESTRUTURA DE REPLICAÇÃO REMOVIDA COM SUCESSO';
  except
    on E: Exception do
      MsgLog := 'ERROR: ' + E.Message;
  end;
end;

procedure TControllerMetadata.SetConexaoLocal(const Value: IControllerConexao);
begin
  FConexaoLocal := Value;
end;

procedure TControllerMetadata.SetLog(const Value: TEvLog);
begin
  FLog := Value;
end;

procedure TControllerMetadata.SetMsgLog(const Value: String);
begin
  if Assigned(FLog) then
    FLog(Value);
  FMsgLog := Value;
end;

end.
