unit umanejador_indices;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TManejador_Indices }

  TManejador_Indices = class
  private
    Fcantidad_total : integer;
    FrespuestasCorrectas: array of integer;
    FimagenesPendientes: array of integer;
    FrespuestasIncorrectas: array of integer;
    FEn_Repaso: boolean;

    procedure longitudes_a_0;
    procedure SetEn_repaso(value:boolean);
    procedure desordenarPendientes;
    procedure descuentaPendiente(i:integer);
  public

    procedure agregarCorrecto(i:integer);
    procedure agregarIncorrecto(i:integer);
    function cantidadCorrectos: integer;
    function cantidadIncorrectos: integer;
    function cantidadPendientes: integer;
    function siguienteIndice: integer;

    constructor Create(cant_total: integer);
    destructor Destroy;

    procedure generaPendientes;
    procedure blanquearRespuestas;

    property En_repaso:boolean read FEn_Repaso write SetEn_repaso;
  end;

implementation

{ TManejador_Indices }

procedure TManejador_Indices.longitudes_a_0;
begin
  SetLength(FimagenesPendientes,0);
  SetLength(FrespuestasCorrectas,0);
  SetLength(FrespuestasIncorrectas,0);
end;

procedure TManejador_Indices.generaPendientes;
var
  i:integer;
begin
  setlength(FimagenesPendientes,Fcantidad_total);
  for i:=0 to high(FimagenesPendientes) do
    FimagenesPendientes[i] := i;
  desordenarPendientes;
end;

procedure TManejador_Indices.blanquearRespuestas;
begin
  setlength(FrespuestasCorrectas,0);
  setlength(FrespuestasIncorrectas,0);
end;

procedure TManejador_Indices.SetEn_repaso(value: boolean);
var
  i:integer;
begin
  //if (FEn_Repaso=value) and not FEn_Repaso then exit;
  FEn_Repaso:=value;

  if FEn_Repaso then
  begin
    SetLength(FimagenesPendientes,length(FrespuestasIncorrectas));
    for i:=0 to high(FrespuestasIncorrectas) do
      FimagenesPendientes[high(FimagenesPendientes)-i] := FrespuestasIncorrectas[i];
  end
  else
    generaPendientes;

  blanquearRespuestas;
end;

procedure TManejador_Indices.desordenarPendientes;
var
  i,j,aux: integer;
begin
  randomize;
  for i:= high(FimagenesPendientes) downto 1 do
    begin
      j:= random(i)+1;
      aux:= FimagenesPendientes[j];
      FimagenesPendientes[j]:= FimagenesPendientes[i];
      FimagenesPendientes[i]:= aux;
    end;
end;

procedure TManejador_Indices.descuentaPendiente(i: integer);
begin
  if i<>FimagenesPendientes[high(FimagenesPendientes)] then
    raise EExternal('Indice a descontar '+inttostr(i)+' difiere de siguiente '+inttostr(FimagenesPendientes[high(FimagenesPendientes)]));
  SetLength(FimagenesPendientes,length(FimagenesPendientes)-1);
end;

procedure TManejador_Indices.agregarCorrecto(i: integer);
begin
  SetLength(FrespuestasCorrectas,Length(FrespuestasCorrectas)+1);
  FrespuestasCorrectas[high(FrespuestasCorrectas)] := i;
  descuentaPendiente(i);
end;

procedure TManejador_Indices.agregarIncorrecto(i: integer);
begin
  SetLength(FrespuestasIncorrectas,Length(FrespuestasIncorrectas)+1);
  FrespuestasIncorrectas[high(FrespuestasIncorrectas)] := i;
  descuentaPendiente(i);
end;

function TManejador_Indices.cantidadCorrectos: integer;
begin
  Result := length(FrespuestasCorrectas);
end;

function TManejador_Indices.cantidadIncorrectos: integer;
begin
  Result := length(FrespuestasIncorrectas);
end;

function TManejador_Indices.cantidadPendientes: integer;
begin
  Result := length(FimagenesPendientes);
end;

function TManejador_Indices.siguienteIndice: integer;
begin
  Result := FimagenesPendientes[high(FimagenesPendientes)];
end;

constructor TManejador_Indices.Create(cant_total: integer);
begin
  Fcantidad_total := cant_total;
  longitudes_a_0;
end;

destructor TManejador_Indices.Destroy;
begin
  longitudes_a_0;
end;

end.

