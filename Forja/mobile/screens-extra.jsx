/* global React, Icon, MobStatus, BackHead, MobHead, TabBar, THEMES, applyTheme */
// Extras: Montar Treino (Personal) + Conquistas + Medidas + Configurações

// ============ MONTAR TREINO (Personal) ============
function MontarTreino() {
  const exs = [
    { nome:"Supino Reto Barra", grupo:"Peito", s:4, r:"8-10", c:80 },
    { nome:"Supino Inclinado Halter", grupo:"Peito", s:3, r:"10", c:28 },
    { nome:"Crucifixo Polia Alta", grupo:"Peito", s:3, r:"12-15", c:15 },
    { nome:"Desenvolvimento Militar", grupo:"Ombro", s:4, r:"8", c:50 },
  ];
  return (
    <div className="mob" data-screen-label="Montar Treino (Personal) — Mobile">
      <MobStatus/>
      <BackHead title="NOVO TREINO · JOÃO P." right={<span style={{ fontSize:12, color:'var(--accent)', fontWeight:700 }}>SALVAR</span>}/>
      <div className="mob-scroll" style={{ paddingTop: 4 }}>
        {/* Nome + objetivo */}
        <div className="card" style={{ padding: 16, marginBottom: 14 }}>
          <div className="label-sm" style={{ marginBottom: 6 }}>Nome do treino</div>
          <input className="input" defaultValue="PUSH A — Peito · Ombro · Tríceps"/>
          <div style={{ display:'flex', gap:6, marginTop: 12, overflow:'auto', paddingBottom: 2 }}>
            {['Hipertrofia','Força','Resistência','Cutting'].map((o,i)=>(
              <span key={i} className={"chip"+(i===0?" solid":"")} style={{ whiteSpace:'nowrap' }}>{o}</span>
            ))}
          </div>
          <div className="label-sm" style={{ margin:'16px 0 8px' }}>Dias do ciclo</div>
          <div style={{ display:'flex', gap:6 }}>
            {['S','T','Q','Q','S','S','D'].map((d,i)=>(
              <div key={i} style={{ flex:1, padding:'10px 0', textAlign:'center', borderRadius:8,
                background: i===3?'var(--accent)':'var(--bg-2)', color: i===3?'var(--accent-fg)':'var(--text-dim)',
                fontSize:12, fontWeight:700 }}>{d}</div>
            ))}
          </div>
        </div>

        {/* Sugestão IA */}
        <div className="card" style={{ padding: 16, marginBottom: 14, borderColor:'color-mix(in oklch, var(--accent) 25%, transparent)' }}>
          <div style={{ display:'flex', alignItems:'center', gap:8 }}>
            <div style={{ width:22, height:22, borderRadius:6, background:'var(--accent)', color:'var(--accent-fg)', display:'flex', alignItems:'center', justifyContent:'center' }}><Icon name="flash" size={12}/></div>
            <span className="label-sm" style={{ color:'var(--accent)' }}>SUGESTÃO IA</span>
          </div>
          <div style={{ fontSize:13, lineHeight:1.5, marginTop:10 }}>
            João bateu <b style={{ color:'var(--accent)' }}>PR no supino inclinado</b>. Subir carga base 26→28kg e +1 série.
          </div>
          <div style={{ display:'flex', gap:8, marginTop:12 }}>
            <button className="btn primary" style={{ flex:1, justifyContent:'center', padding:'8px' }}>Aplicar</button>
            <button className="btn ghost" style={{ flex:1, justifyContent:'center', padding:'8px' }}>Ignorar</button>
          </div>
        </div>

        {/* Lista de exercícios */}
        <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom: 10, padding:'0 2px' }}>
          <span className="label-sm">4 exercícios · 14 séries</span>
          <span style={{ fontSize:12, color:'var(--accent)', fontWeight:600 }}>Reordenar</span>
        </div>
        <div className="col gap-3">
          {exs.map((e,i)=>(
            <div key={i} className="card" style={{ padding:'12px 14px' }}>
              <div style={{ display:'flex', alignItems:'center', gap:12 }}>
                <span style={{ color:'var(--text-faint)', fontSize:16 }}>⋮⋮</span>
                <div className="f-display" style={{ fontSize:20, color:'var(--text-dim)', width:22 }}>{i+1}</div>
                <div style={{ flex:1, minWidth:0 }}>
                  <div style={{ fontSize:14, fontWeight:600 }}>{e.nome}</div>
                  <div style={{ fontSize:11, color:'var(--text-dim)', marginTop:2 }}>{e.grupo} · {e.s}×{e.r} · {e.c}kg</div>
                </div>
                <Icon name="more" size={18}/>
              </div>
            </div>
          ))}
        </div>
        <button className="btn ghost cta" style={{ marginTop: 14, borderStyle:'dashed' }}><Icon name="plus" size={16}/> Adicionar exercício</button>
      </div>
      <div style={{ padding:'12px 16px 28px', borderTop:'1px solid var(--hairline)', background:'#0a0b0c' }}>
        <button className="btn primary cta">PUBLICAR PARA JOÃO</button>
      </div>
    </div>
  );
}

// ============ CONQUISTAS ============
function Conquistas() {
  const badges = [
    { ico:"flame",   nome:"30 dias seguidos", on:true },
    { ico:"trophy",  nome:"Primeiro PR", on:true },
    { ico:"flash",   nome:"10 PRs no mês", on:true },
    { ico:"dumbbell",nome:"100t movidas", on:true },
    { ico:"calendar",nome:"100 treinos", on:false, prog:"84/100" },
    { ico:"timer",   nome:"Madrugador", on:false, prog:"12/20" },
  ];
  return (
    <div className="mob" data-screen-label="Conquistas — Mobile">
      <MobStatus/>
      <MobHead over="14 desbloqueadas · 8 a caminho" title="CONQUISTAS"/>
      <div className="mob-scroll" style={{ paddingTop: 4 }}>
        {/* Destaque */}
        <div className="card card-accent" style={{ padding: 20, marginBottom: 16, position:'relative', overflow:'hidden' }}>
          <div style={{ position:'absolute', right:-20, top:-20, opacity:0.12, color:'#000' }}><Icon name="flame" size={160}/></div>
          <div style={{ position:'relative' }}>
            <div className="eyebrow" style={{ color:'rgba(0,0,0,0.55)' }}>SEQUÊNCIA ATUAL</div>
            <div className="f-display" style={{ fontSize: 72, lineHeight:0.9 }}>17 DIAS</div>
            <div style={{ fontSize:13, color:'rgba(0,0,0,0.7)' }}>Faltam 13 para seu recorde de 30!</div>
          </div>
        </div>

        <div className="label-sm" style={{ marginBottom: 12 }}>MEDALHAS</div>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap: 10 }}>
          {badges.map((b,i)=>(
            <div key={i} className="card" style={{ padding:14, textAlign:'center', opacity: b.on?1:0.5 }}>
              <div style={{ width:52, height:52, borderRadius:'50%', margin:'0 auto',
                background: b.on?'var(--accent)':'var(--bg-3)', color: b.on?'var(--accent-fg)':'var(--text-faint)',
                display:'flex', alignItems:'center', justifyContent:'center' }}>
                <Icon name={b.ico} size={24}/>
              </div>
              <div style={{ fontSize:11, marginTop:8, lineHeight:1.3, fontWeight:600 }}>{b.nome}</div>
              {b.prog && <div className="f-mono" style={{ fontSize:10, color:'var(--text-dim)', marginTop:3 }}>{b.prog}</div>}
            </div>
          ))}
        </div>
      </div>
      <TabBar active="perfil"/>
    </div>
  );
}

// ============ MEDIDAS CORPORAIS ============
function Medidas() {
  const data = [82.4,82.0,81.6,81.8,81.2,80.9,80.4,80.1];
  const max = Math.max(...data), min = Math.min(...data), w=320, h=120;
  const pts = data.map((v,i)=>`${(i/(data.length-1))*w},${h-((v-min)/(max-min))*h*0.8-10}`).join(' ');
  const medidas = [
    { l:"Peso", v:"80,1", u:"kg", d:"−2,3kg", c:'var(--success)' },
    { l:"% Gordura", v:"13,8", u:"%", d:"−0,9pp", c:'var(--success)' },
    { l:"Massa magra", v:"71,2", u:"kg", d:"+1,1kg", c:'var(--success)' },
    { l:"Peito", v:"107", u:"cm", d:"+2cm", c:'var(--accent)' },
    { l:"Braço", v:"42,5", u:"cm", d:"+1,2cm", c:'var(--accent)' },
    { l:"Cintura", v:"81", u:"cm", d:"−2cm", c:'var(--success)' },
  ];
  return (
    <div className="mob" data-screen-label="Medidas Corporais — Mobile">
      <MobStatus/>
      <BackHead title="MEDIDAS" right={<Icon name="plus" size={20}/>}/>
      <div className="mob-scroll" style={{ paddingTop: 4 }}>
        <div className="card" style={{ padding: 18, marginBottom: 16 }}>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'baseline' }}>
            <div className="label-sm">Peso · 8 semanas</div>
            <span style={{ fontSize:12, color:'var(--success)' }}>↘ −2,3kg</span>
          </div>
          <div style={{ display:'flex', alignItems:'baseline', gap:6, marginTop:4 }}>
            <div className="f-display" style={{ fontSize:52 }}>80,1</div>
            <span className="stat-unit">kg</span>
          </div>
          <svg viewBox={`0 0 ${w} ${h}`} width="100%" style={{ marginTop: 8, display:'block' }}>
            <polyline points={pts} fill="none" stroke="var(--accent)" strokeWidth="2.5"/>
            {data.map((v,i)=>{ const x=(i/(data.length-1))*w, y=h-((v-min)/(max-min))*h*0.8-10;
              return <circle key={i} cx={x} cy={y} r={i===data.length-1?5:3} fill={i===data.length-1?'var(--accent)':'var(--bg-0)'} stroke="var(--accent)" strokeWidth="2"/>; })}
          </svg>
        </div>

        <div className="label-sm" style={{ marginBottom: 12 }}>ÚLTIMA AVALIAÇÃO · 18 MAI</div>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap: 10 }}>
          {medidas.map((m,i)=>(
            <div key={i} className="kpi" style={{ padding: 16 }}>
              <div className="stat-label" style={{ fontSize:10 }}>{m.l}</div>
              <div className="v" style={{ fontSize:32 }}>{m.v}<span className="stat-unit" style={{ fontSize:13 }}>{m.u}</span></div>
              <div style={{ fontSize:11, color:m.c, marginTop:2 }}>{m.d}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ============ CONFIGURAÇÕES (com seletor de tema nativo) ============
function Configuracoes() {
  const themes = (typeof THEMES !== 'undefined' && THEMES) ? THEMES : [
    { id:'lime', name:'Lime', accent:'#d4ff3a' },
  ];
  const [sel, setSel] = React.useState(() => {
    try { return localStorage.getItem('forja-theme') || 'lime'; } catch { return 'lime'; }
  });
  React.useEffect(() => {
    const t = themes.find(x => x.id === sel);
    if (t && typeof applyTheme === 'function') applyTheme(t);
    try { localStorage.setItem('forja-theme', sel); } catch {}
  }, [sel]);

  const toggles = [
    { l:"Sons no cronômetro", on:true },
    { l:"Vibrar ao concluir série", on:true },
    { l:"Notificação de descanso", on:true },
    { l:"Lembrete diário de treino", on:false },
    { l:"Resumo semanal por email", on:false },
  ];
  return (
    <div className="mob" data-screen-label="Configurações — Mobile">
      <MobStatus/>
      <BackHead title="PREFERÊNCIAS"/>
      <div className="mob-scroll" style={{ paddingTop: 4 }}>
        {/* Tema / acento */}
        <div className="card" style={{ padding: 18, marginBottom: 14 }}>
          <div className="label-sm" style={{ marginBottom: 14 }}>COR DE ACENTO</div>
          <div style={{ display:'flex', gap: 14, justifyContent:'space-between' }}>
            {themes.map(t => (
              <button key={t.id} onClick={() => setSel(t.id)}
                style={{ width:42, height:42, borderRadius:'50%', background:t.accent, cursor:'pointer', padding:0,
                  border: sel===t.id ? '3px solid var(--text)' : '3px solid transparent',
                  boxShadow: sel===t.id ? `0 0 0 1px ${t.accent}` : 'none' }}/>
            ))}
          </div>
          <div style={{ fontSize:12, color:'var(--text-dim)', marginTop:12 }}>
            Tema atual: <b style={{ color:'var(--accent)' }}>{(themes.find(t=>t.id===sel)||{}).name}</b>
          </div>
        </div>

        {/* Unidades */}
        <div className="card" style={{ padding: 18, marginBottom: 14 }}>
          <div className="label-sm" style={{ marginBottom: 12 }}>UNIDADES</div>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center', marginBottom: 14 }}>
            <span style={{ fontSize:14 }}>Carga</span>
            <div className="seg" style={{ width: 120 }}><button className="on">kg</button><button>lb</button></div>
          </div>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
            <span style={{ fontSize:14 }}>Medidas</span>
            <div className="seg" style={{ width: 120 }}><button className="on">cm</button><button>in</button></div>
          </div>
        </div>

        {/* Toggles */}
        <div className="card" style={{ padding: '6px 18px' }}>
          {toggles.map((t,i)=>(
            <div key={i} style={{ display:'flex', justifyContent:'space-between', alignItems:'center', padding:'14px 0', borderBottom: i<toggles.length-1?'1px solid var(--hairline)':'none' }}>
              <span style={{ fontSize:14 }}>{t.l}</span>
              <div style={{ width:42, height:24, borderRadius:99, background: t.on?'var(--accent)':'var(--bg-3)', position:'relative' }}>
                <div style={{ position:'absolute', top:3, left: t.on?21:3, width:18, height:18, borderRadius:'50%', background: t.on?'var(--accent-fg)':'#fff' }}/>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { MontarTreino, Conquistas, Medidas, Configuracoes });
