unit upractica_hav5;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  StrUtils,
  lazpng,
  umanejador_indices;

type

  { TForm1 }

  TForm1 = class(TForm)
    btRespuesta: TButton;
    btCorrecto: TButton;
    btIncorrecto: TButton;
    btTerminar: TButton;
    btComenzar: TButton;
    Image1: TImage;
    lbInfo: TLabel;
    lbRespuesta: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure btComenzarClick(Sender: TObject);
    procedure btIncorrectoClick(Sender: TObject);
    procedure btRespuestaClick(Sender: TObject);
    procedure btCorrectoClick(Sender: TObject);
    procedure btTerminarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure muestraimagen(i:integer);
    procedure siguienteimagen;
    procedure ActualizaInfo;
  private
    listaImagenes: TStringList;
    mi: TManejador_Indices;
    //imagenesPendientes: array of integer;
    //respuestasCorrectas: array of integer;
    //respuestasIncorrectas: array of integer;
    //respuestasRepaso: array of integer;
    imagenact:string;
    indiceact:integer;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}



{ TForm1 }

procedure TForm1.FormShow(Sender: TObject);
begin
  btCorrecto.Enabled := False;
  btIncorrecto.Enabled := False;
  lbRespuesta.Caption := '';
  muestraimagen(mi.siguienteIndice);
  ActualizaInfo;
  btRespuesta.Enabled := True;
end;

procedure TForm1.muestraimagen(i: integer);
var
  png : TPNGImage;
  pngw,pngh,imgw,imgh: integer;
  dest: TRect;
begin
  png := TPNGImage.Create;
  try
    indiceact := i;
    imagenact := listaImagenes[i];
    png.LoadFromFile(imagenact);
    pngw := png.Width;
    pngh := png.Height;
    imgw := Image1.Width;
    imgh := Image1.Height;

    if pngh/pngw>imgh/imgw then
    begin
      dest.Top := 0;
      dest.Bottom := imgh;
      dest.Left := (imgw - (pngw * imgh div pngh)) div 2;
      dest.Right := (pngw * imgh div pngh) + dest.Left;
    end
    else
    begin
      dest.Left := 0;
      dest.Right := imgw;
      dest.Top := (imgh - (pngh * imgw div pngw)) div 2;
      dest.Bottom := (pngh * imgw div pngw) + dest.Top;
    end;

    Image1.Canvas.Clear;
    Image1.Canvas.StretchDraw(dest,png);
  finally
    FreeAndNil(png);
  end;
end;

procedure TForm1.siguienteimagen;
var
  cand: integer;
  candok: boolean;
  i: integer;
begin
  btCorrecto.Enabled := False;
  btIncorrecto.Enabled := False;
  lbRespuesta.Caption := '';
  if not mi.En_repaso then
  begin
    if mi.cantidadPendientes<1 then
    begin
      ShowMessage('ESTUDIO TERMINADO');
      mi.generaPendientes;
      Exit;
    end;

   cand := mi.siguienteIndice;
  end
  else
  begin
    if mi.cantidadPendientes<1 then
    begin
      ShowMessage('REPASO TERMINADO');
      Exit;
    end;
    cand := mi.siguienteIndice;
  end;
  muestraimagen(cand);
  ActualizaInfo;
  btRespuesta.Enabled := True;
end;

procedure TForm1.ActualizaInfo;
var
 s: string;
begin
  s:=inttostr(indiceact)+' ';
  //s := '';
  if not mi.En_repaso then
  begin
    s := s+ 'General  ';
  end
  else
  begin
    s := s+ 'Repaso  ';
  end;
  s := s+'Faltantes: '+inttostr(mi.cantidadPendientes);
  s := s+' Correctas: '+inttostr(mi.cantidadCorrectos)+' Incorrectas: '+inttostr(mi.cantidadIncorrectos);
  lbInfo.Caption:=s;
end;

procedure TForm1.FormCreate(Sender: TObject);
  procedure listadir(d:string);
  var
    SR: TSearchRec;
  begin
    if FindFirst(d+PathDelim+'*',faAnyFile,SR)=0 then
    begin
      repeat
        if pos('.',SR.Name)=1 then
          continue
        else if SR.Attr and faDirectory<>0 then
          listadir(d+PathDelim+SR.Name)
        else if pos('.png',SR.Name)>0 then
          listaImagenes.Add(d+PathDelim+SR.Name);
      until FindNext(SR)<>0;
      FindClose(SR);
    end;
  end;

begin
  listaImagenes := TStringList.Create;
  listadir('imagenes');
  if listaImagenes.Count=0 then
    ShowMessage('NO SE ENCONTRARON IMAGENES');
  // while listaImagenes.Count>10 do
  //  listaImagenes.Delete(10);
  mi := TManejador_Indices.Create(listaImagenes.Count);
  Randomize;
  mi.generaPendientes;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  mi.Free;
  listaImagenes.Free;
end;

procedure TForm1.btCorrectoClick(Sender: TObject);
begin
  mi.agregarCorrecto(indiceact);
  siguienteimagen;
end;

procedure TForm1.btTerminarClick(Sender: TObject);
var
  i:integer;
begin
  if mi.cantidadIncorrectos>0 then
  begin
    if MessageDlg('Desea realizar un repaso de las que respondio incorrectamente?',mtConfirmation,[mbYes, mbNo],0)=mrYes then
    begin
      mi.En_repaso:=True;
      siguienteimagen;
      exit;
    end
  end
  else
    mi.En_repaso:=False;
  mi.blanquearRespuestas;
  btTerminar.Visible:=False;
  btComenzar.Visible:=True;
end;


procedure TForm1.btRespuestaClick(Sender: TObject);
begin
  btRespuesta.Enabled := False;
  lbRespuesta.Caption := AnsiReplaceStr(AnsiReplaceStr(copy(imagenact,1,length(imagenact)-4),PathDelim,' - '),'imagenes -','');
  btCorrecto.Enabled := True;
  btIncorrecto.Enabled := True;
end;

procedure TForm1.btIncorrectoClick(Sender: TObject);
begin

  mi.agregarIncorrecto(indiceact);
  siguienteimagen;
end;

procedure TForm1.btComenzarClick(Sender: TObject);
begin
  btTerminar.Visible:=True;
  btComenzar.Visible:=False;
  siguienteimagen;
end;

end.

