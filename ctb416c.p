/*****************************************************************************

     DATACOPER   ****    SISTEMA.....: CONTABILIDADE
CONSULTORIA   E  ****                  
SISTEMAS   LTDA  ****    PROGRAMA....: CTB416C.P
                 ****
                 ****    FUNCAO......: BALANCO PATRIMONIAL - SOMENTE D.R.E.
       ***       ****                  POR INTERVALO DE MESES
     ****  ***   ****    RESPONSAVEL.: FRANCISCO CESAR CAMPANA
   *****  *****  ****
 *****     ***  *****    OBS.........: ULTIMA ALTERACAO EM 18/10/2001 
********************     ALTERACAO...: MARA - 31/07/2002 - Seletor de unidades  
 ******************      ALTERACAO...: MARA - 30/09/2002 - Area de negocio
                                       Jaime 07/04/2005 - Ajustes no DRE
*****************************************************************************/
&if defined(RetornarVersao_ctb416c_p) > 0 &then
    &GLOBAL Versao_ctb416c_p 2014.06.24
&else
{ver500aa.i &Arquivo = ctb04801 &Extensao = up  &VersaoBase = 2014.06.24}.
{ver500aa.i &Arquivo = ctb209   &Extensao = p   &VersaoBase = 2014.06.24}.
{ver500aa.i &Arquivo = ctb248   &Extensao = p   &VersaoBase = 2014.06.24}.
{ver500aa.i &Arquivo = ctb251   &Extensao = p   &VersaoBase = 2014.06.24}.
{ver500aa.i &Arquivo = est224   &Extensao = p   &VersaoBase = 2014.06.24}. 
/*
  Cadastrar areas de negocio na rotina ctb248.p.
  Relacionar contas de estoque com area de negocio na rotina est224.p.
  Relacionar as contas de servico com area de negocio na rotina ctb251.p.
  Relacionar centros de custo com area de negocio na rotina ctb209.p.
     Nao foi encontrado nenhum cliente onde a rotina ctb209.p tenha acesso ao
     campo area de negocio. Tambem nao foi encontrada nenhuma outra rotina 
     para relacionar centro de custo com area de negocio.
     Verificar se o processo e realmente funciona.
     A rotina ctb209.p do main foi ajustada para acessar o campo
     area-de-negocio em 24/06/2014 por Renato Sochodolak
  Ver rotinas dre210.p, dre211.p e dre410.p que apresentam o demonstrativo 
  por area de negocio.
*/
{shared.i}.
{msg999dc.i &idecademp0 = * }.
{msg999a.w
   &new = new
   }.
{device.w}.
{cademp91.w}.
{ctb04891.w}.

def temp-table resumo
    field empresa   like ctb003.empresa
    field conta     like ctb003.conta
    field saldo     as dec format 'zzz,zzz,zzz,zz9.99-'
   index resumo-1 is unique
         empresa
         conta.

def var ok              as log.
def var w-mes           as int  format    '99' no-undo.
def var w-mesf          as int  format    '99' no-undo.
def var w-dia           as int  format    '99'.
def var w-ano           as int  format  '9999' no-undo.
def var w-nivel         as int  format     '9' no-undo.
def var w-superior      like ctb001.superior.
def var x               as int format '99'.
def var x1              as int.
def var w-unidade       like cademp.unidade         no-undo.
def var w-areaneg       like ctb048.area-de-negocio no-undo.
def var z               as int.
def var z1              as int.
def var descricao       like ctb001.descricao.
def var saldo-acum      as dec format 'zzz,zzz,zzz,zz9.99-'.
def var vlr-imp         as dec format 'zzz,zzz,zzz,zz9.99-'.
def var pagina          as int format 'zz99'.
def var w-plano         as log format 'Sim/Nao' initial no.
def var w-valor         as dec format 'zzz,zzz,zzz,zz9.99-'.
def var z-total         as dec format 'zzz,zzz,zzz,zz9.99-' extent 26.
def var z-valor         as dec format 'zzz,zzz,zzz,zz9.99-' extent 99.
def var z-descricao     as char format 'x(50)'              extent 99.
def var cab-titulo3     as char.
def var ws-descricao    as char.
def var ws-des-ctb048                  like ctb048.descricao  no-undo.

form w-unidade    label 'Unidade...........'
     cademp.sigla no-label                   skip
     w-mes        label 'Mes inicial.......' skip
     w-mesf       label 'Mes final.........' skip
     w-ano        label 'Ano a listar......' skip
     w-nivel      label 'Nivel a listar....' skip
     w-areaneg    label 'Area de negocio...' ws-des-ctb048 no-label skip
     w-plano      label 'Encad livro diario' skip
     pagina       label 'Ultima pagina.....' skip
     with 1 down row 5 side-labels frame dados centered overlay width 78
     title ' BALANCO PATRIMONIAL '.

form ok with 1 down 1 col row 21 no-box frame confirma col 6.
                                                           
form header
     'Ref:' at 1 string(sc-procedure,'x(8)') today string(time,'HH:MM:SS')
     with frame cab-ent3 page-bottom no-label no-box width 255.

view frame dados.
pause 0.
repeat 
   with frame dados:

   message
        'ATENCAO: ' skip(1)
        '*** Este programa ira gerar o balanco patrimonial por periodo, ' 
        skip(1)
        'mas somente o D.R.E.' skip(1)
        '*** As contas de resultado serao acumuladas o movimento do periodo. '
        skip(1)
        '*** Este balancete nao considera as contas do compensado.'
        view-as alert-box title userid(ldbname(1)).
            
  
   hide frame plano.
   hide frame pag.
   pagina = 0.

   {cademp91.up 
      &unidade = w-unidade 
      &off     = yes
      }.
      
   assign cab-titulo3 = ''.
   if w-unidade = 00 then
      disp 'TODAS' @ cademp.sigla.
   else
      assign cab-titulo3 = 'Unidade: ' +
                           cademp.sigla.
  ok = yes.
  
  for each cademps.
      if cademps.marca = no then
         do.
            ok = no.
            leave.
         end.
  end.    
   
  find first cademp
       where cademp.empresa = sh-empresa 
         and cademp.unidade = 00     
       no-error.

   update w-mes   validate(w-mes > 0 and w-mes < 13,'Mes invalido!').
   update w-mesf  validate(w-mesf >= w-mes and w-mesf < 13,
                 'Mes final deve ser maior o igual o mes inicial!').
   update w-ano  
          validate (w-ano ne 0,'').
   update w-nivel.
   w-dia={lastday.i date(w-mesf,01,w-ano)}.
   
   {ctb04891.up 
      &area-de-negocio = w-areaneg
      &Off             = yes
      &disp            = "ctb048.descricao @ ws-des-ctb048"
      &disp2           = ws-des-ctb048
      }.
                 
   update w-plano
          help  'Encadernacao no livro diario ? ' .
          
   if w-plano=yes then
      do:
          find last cadpgn share-lock 
              where cadpgn.empresa  = sh-empresa     
                and cadpgn.unidade  = w-unidade      
                and cadpgn.esp-dcto = 'ctb408'      
                and cadpgn.serie    = ' '            
              no-error.

          if not avail cadpgn then
             do:
                create cadpgn.
                assign cadpgn.empresa  = sh-empresa
                       cadpgn.unidade  = w-unidade
                       cadpgn.esp-dcto = 'ctb408'
                       cadpgn.serie    = ' '
                       cadpgn.descricao='livro diario'.
             end.
          pagina=cadpgn.ult-folha.
          update pagina
                 help 'Informe a ultima pagina emitida.'.
      end.
/*   pagina=pagina + 1.*/
   
   {devices.i}.

   for each resumo.
       delete resumo.
   end.    

   run MONTA-DRE         IN THIS-PROCEDURE.
   run LISTA-DRE         IN THIS-PROCEDURE.
   run LISTA-DRE-SELECAO IN THIS-PROCEDURE.
   run LISTA-DIRETORES   IN THIS-PROCEDURE.

   do x = 1 to 26:
      z-total[x]=0.
   end.

   {devicef.i}.
   
   if w-plano = yes
        then cadpgn.ult-folha=pagina.
end.

   /****** MONTA RELATORIO PARA D.R.E.  *******/
   
PROCEDURE MONTA-DRE.
   
   for each resumo.
       delete resumo.
   end.
   
   /* 07/04/2005 */
   for each ctb011
      where ctb011.empresa     = sh-empresa
        and ctb011.resultado   = ''
      ,
       each ctb001 
      where ctb001.empresa     = sh-empresa
        and ctb001.conta  begins '3'       
        and ctb001.tipo        = no
        and substr(ctb001.ind-aux[1],1,1) = ctb011.item
      ,
       each cademps
      where cademps.marca      = yes
      ,
      first ctb003 
      where ctb003.empresa   = ctb001.empresa
        and ctb003.unidade   = cademps.unidade
        and ctb003.exercicio = w-ano          
        and ctb003.conta     = ctb001.conta
      .

      /* if w-areaneg ne 0 then */
      if can-find(first ctb048s
                  where ctb048s.marca = yes) then
         do.
            if ctb001.conta-origem matches '*ce*' then
               do.
                  find first est024
                       where est024.empresa = sh-empresa
                         and est024.conta   = ctb001.integra-conta
                       no-error.
                  if not avail est024 then next.
                  find first ctb048s
                       where ctb048s.area-de-negocio = est024.area-de-negocio
                         and ctb048s.marca           = yes
                       no-error.
                  if not avail ctb048s then next.
               end.
            else
            if ctb001.conta-origem matches '*cc*' then
               do.
                  find first ctb019
                       where ctb019.empresa = sh-empresa
                         and ctb019.conta   = ctb001.integra-conta
                       no-error.
                  if not avail ctb019 then next.
                  find first ctb048s
                       where ctb048s.area-de-negocio = ctb019.area-de-negocio
                         and ctb048s.marca           = yes
                      no-error.
                 if not avail ctb048s then next.
               end.       
            else
            if ctb001.conta-origem matches '*sp*' then
               do.
                  find first ctb251
                       where ctb251.empresa = sh-empresa
                         and ctb251.conta   = ctb001.integra-conta
                       no-error.  
                  if not avail ctb251 then next.

                  find first ctb048s
                       where ctb048s.area-de-negocio = ctb251.area-de-negocio
                         and ctb048s.marca = yes
                       no-error.
                  if not avail ctb048s then next.
               end.
         end.

      find first resumo share
           where resumo.conta   = ctb003.conta
             and resumo.empresa = ctb003.empresa
           no-error.
      if not avail resumo then
         do.
            create resumo.
            assign resumo.empresa   = ctb003.empresa
                   resumo.conta     = ctb003.conta.
         end.
              
      do x1 = w-mes to w-mesf.
          resumo.saldo = resumo.saldo +
                       (ctb003.debito[x1] - ctb003.credito[x1]).
      end.
   end. 
   
   ws-descricao = ''.
   for each cademps
       where cademps.marca = yes.
       assign ws-descricao = ws-descricao + cademps.sigla + ', '.
   end.
                         
END.


PROCEDURE LISTA-DRE-SELECAO.

   for each ctb011 
      where ctb011.empresa = sh-empresa.
       if ctb011.resultado ne ' ' then
          do:
              w-valor = 0.
              do x = 1 to 10:
                z1 = lookup(substr(ctb011.resultado,x,1),
                     'A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,-,+').
                if z1  = 0  then next.
                if z1 >= 1 and z1 < 27 then
                   do:
                      w-valor = w-valor + z-total[z1].
                   end.
             end.
             z1=lookup(ctb011.item,
                         'A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z').
             z-total[z1]=w-valor.
             if line-counter >= 55 then
                do:
                   pagina=pagina + 1.
                   page.
                   put
                      space(63) 'PAGINA: ' pagina chr(13) format 'x(1)'
                      space(63) 'PAGINA: ' pagina skip(1).
                end.

             vlr-imp = z-total[z1] * -1.
             put skip(1)
                 ctb011.descr  space(6) vlr-imp  chr(13) format 'x(1)'
                 ctb011.descr  space(6) vlr-imp.
             next.
          end.
       else
         for each ctb001 
            where ctb001.empresa  = ctb011.empresa   
              and ctb001.conta      begins '3'       
              and ctb001.tipo     = no
              and substr(ctb001.ind-aux[1],1,1) = ctb011.item.
             find first resumo 
                  where resumo.empresa   = ctb001.empresa 
                    and resumo.conta     = ctb001.conta  
                   no-error.
             if not avail resumo then next.
             if resumo.saldo   = 0 then next.
             z = lookup(substr(ctb001.ind-aux[1],2,2),
                '01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,' +
                '20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,' +
                '38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,' +
                '57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,' +
                '76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,' +
                '95,96,97,98,99').
             z1 = lookup(ctb011.item,
                  'A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z').
             if substr(ctb001.ind-aux[1],2,2)=' '
                then z-total[z1] = z-total[z1] + resumo.saldo.
             if z = 0 then next.
             assign
                z-valor    [z]   = z-valor[z] + resumo.saldo
                z-descricao[z]   = ctb011.sub-descricao[z]
                z-total    [z1]  = z-total[z1] + resumo.saldo.
         end.
         z1 = lookup(ctb011.item,
                        'A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z').
         if line-counter >= 55 then
            do:
               pagina=pagina + 1.
               page.
               put
                  space(63) 'PAGINA: ' pagina chr(13) format 'x(1)'
                  space(63) 'PAGINA: ' pagina skip(1).
            end.
         x1   = 0.
         do x = 1 to 99:
            if line-counter >= 55 then
               do:
                  pagina=pagina + 1.
                  page.
                  put
                     space(63) 'PAGINA: ' pagina chr(13) format 'x(1)'
                     space(63) 'PAGINA: ' pagina skip(1).
               end.
            if z-valor[x] ne 0 or z-total[z1] ne 0 then
               do:
                  if x1=0 then
                     do:
                        vlr-imp=z-total[z1] * -1.
                        put skip(1)
                            ctb011.descr space(6) vlr-imp chr(13) format 'x(1)'
                            ctb011.descr space(6) vlr-imp skip.
                        x1=1.
                     end.
                  vlr-imp=z-valor[x]  * -1.
                  if z-valor[x] ne 0 then
                     put 
                       space(6) z-descricao[x] vlr-imp skip.
                  z-valor[x]     = 0.
                  z-descricao[x] = ' '.
               end.
         end.
   end.
   
END.


PROCEDURE LISTA-DIRETORES.

   if line-counter >= 44 and
      cademp.diretor[2] ne ' ' then
      do:
         pagina=pagina + 1.
         page.
         put
            space(63) 'PAGINA: ' pagina chr(13) format 'x(1)'
            space(63) 'PAGINA: ' pagina skip.
      end.
   if line-counter >= 55   and
      cademp.diretor[2] = ' ' then
      do:
         pagina=pagina + 1.
         page.
         put
            space(63) 'PAGINA: ' pagina chr(13) format 'x(1)'
            space(63) 'PAGINA: ' pagina skip.
      end.
   put
      skip(2)
      space(26)
      trim(caps(cademp.cidade) + ' ' + caps(cademp.uf) + ', ' + string(w-dia) +~ ' DE ' + caps({month.i w-mesf}) + ' DE ' + string(w-ano,'9999')) format 'x(40)'
      skip(6)
      '----------------------------------------' at 1
      '----------------------------------------' at 42 skip
      cademp.diretor[1]  format 'x(40)' at 1.
   if cademp.diretor[2] = ' '
      then put cademp.contador format 'x(40)' at 42.
   else put cademp.diretor[2]  format 'x(40)' at 42.
   put skip
       cademp.cargo[1] at 1.
   if cademp.diretor[2] = ' ' then
      put cademp.cargo-contador at 42.
   else put cademp.cargo[2]   at 42.
   put skip.
   if cademp.cpf[1] ne '00000000000' then
      put 'CPF ' at 1 cademp.cpf[1].
   if cademp.diretor[2] = ' '
      then put 'CRC ' at 42 cademp.crc.
   else 
   if cademp.cpf[2] ne '00000000000' then
      put 'CPF ' at 42 cademp.cpf[2].
   put skip(4).
   if cademp.diretor[2] ne  ' ' then
      do:
         if cademp.diretor[3] = ' ' then
            put '----------------------------------------' at 20 skip
                cademp.contador        at 20 skip
                cademp.cargo-contador  at 20 skip
                'CRC '                 at 20 cademp.crc.
         else  
            put '----------------------------------------'    at 1
                '----------------------------------------'   at 42 skip
                cademp.diretor[3] format 'x(40)'  at 1
                cademp.contador   format 'x(40)'  at 42 skip
                cademp.cargo[3]                   at 1
                cademp.cargo-contador             at 42 skip
                'CPF '  at 1  cademp.cpf[3]
                'CRC '  at 42 cademp.crc.
      end. 
      
END.

PROCEDURE LISTA-DRE.

   page.
   pagina=pagina + 1.
   put
      space(63) 'PAGINA: ' pagina chr(13) format 'x(1)'
      space(63) 'PAGINA: ' pagina skip
      space(16) cademp.razao-social chr(13) format 'x(1)'
      space(16) cademp.razao-social skip
      space(26) 'CGC/MF '  format 'x(7)'
                   cademp.cgc  format '99.999.999/9999-99' chr(13) format 'x(1)'
      space(26) 'CGC/MF ' format 'x(7)'
                   cademp.cgc  format '99.999.999/9999-99' skip(1)
      space(10)
      'DEMONSTRACAO DE RESULTADO REFERENTE AO PERIODO DE ' skip
      space(18)
      caps({month.i w-mes}) + ' DE ' + string(w-ano,'9999') + ' A ' +
      caps({month.i w-mesf}) + ' DE ' + string(w-ano,'9999')
       format 'x(40)' skip
      'Unidade: ' substr(ws-descricao,1,66) format 'x(66)'  skip.
   if substr(ws-descricao,66,66) ne ' ' then
      put substr(ws-descricao,66,66) format 'x(66)' at 10 skip.
   if substr(ws-descricao,132,66) ne ' ' then
      put substr(ws-descricao,132,66) format 'x(66)' at 10 skip.
   if substr(ws-descricao,198,66) ne ' ' then
      put substr(ws-descricao,198,66) format 'x(66)' at 10 skip.
      
   put fill('-',75) format 'x(75)'   chr(13) format 'x(1)'
      fill('-',75) format 'x(75)'   skip
      'DISCRIMINACAO' space(53) ' VALOR R$' chr(13) format 'x(1)'
      'DISCRIMINACAO' space(53) ' VALOR R$' skip
      fill('-',75) format 'x(75)'   chr(13) format 'x(1)'
      fill('-',75) format 'x(75)'   skip(1).

      vlr-imp = 0.

END.


hide frame dados no-pause.
&endif

