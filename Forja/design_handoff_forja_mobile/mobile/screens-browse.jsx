/* global React, Icon, MobStatus, Phone, TabBar, MobHead */
// Dashboard / Hoje + Semana + Biblioteca

function DashHoje() {
  return (
    <div className="mob" data-screen-label="Dashboard / Hoje — Mobile">
      <MobStatus/>
      <MobHead over="Qui · 21 mai" title="BOM DIA, LUCAS"
               right={<div className="nav-avatar" style={{ width:42, height:42, fontSize:20 }}>L</div>}/>
      <div className="mob-scroll">
        {/* Hero treino de hoje */}
        <div className="card card-accent" style={{ padding: 22, marginBottom: 14, position:'relative', overflow:'hidden' }}>
          <div style={{ position:'absolute', right:-30, top:-30, fontFamily:'var(--f-display)', fontSize:220, opacity:0.08, color:'#000' }}>04</div>
          <div style={{ position:'relative' }}>
            <div className="eyebrow" style={{ color:'rgba(0,0,0,0.55)' }}>HOJE · DIA 04 / 06</div>
            <h1 className="f-display" style={{ fontSize: 68, lineHeight:0.85, margin:'4px 0' }}>PUSH</h1>
            <div style={{ fontSize:13, color:'rgba(0,0,0,0.7)' }}>Peito · Ombro · Tríceps</div>
            <div style={{ display:'flex', gap:14, marginTop:14, fontFamily:'var(--f-mono)', fontSize:12 }}>
              <span><b>7</b> exercícios</span><span><b>62</b>min</span><span><b>8.4t</b> volume</span>
            </div>
            <button className="btn lg" style={{ background:'#0a0a0a', color:'var(--accent)', borderColor:'#0a0a0a', width:'100%', justifyContent:'center', marginTop:16 }}>
              <Icon name="play" size={14}/> COMEÇAR TREINO
            </button>
          </div>
        </div>

        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:10, marginBottom:14 }}>
          <div className="kpi"><div className="stat-label">Streak</div><div className="v">17<span className="stat-unit" style={{ fontSize:13 }}>dias</span></div></div>
          <div className="kpi"><div className="stat-label">Vol. semana</div><div className="v">32.8<span className="stat-unit" style={{ fontSize:13 }}>t</span></div></div>
        </div>

        {/* Semana mini */}
        <div className="card" style={{ padding: 16, marginBottom: 14 }}>
          <div style={{ display:'flex', justifyContent:'space-between', alignItems:'center' }}>
            <span className="label-sm">SEMANA 22</span>
            <span className="chip">Hipertrofia</span>
          </div>
          <div style={{ display:'flex', gap:6, marginTop:14, justifyContent:'space-between' }}>
            {['S','T','Q','Q','S','S','D'].map((d, i) => {
              const states = [{done:1},{done:1},{rest:1},{today:1},{},{},{rest:1}];
              const st = states[i];
              return (
                <div key={i} style={{ flex:1, padding:'10px 4px',
                  background: st.today ? 'var(--accent)' : st.rest ? 'transparent' : 'var(--bg-2)',
                  color: st.today ? 'var(--accent-fg)' : st.rest ? 'var(--text-faint)' : 'var(--text)',
                  borderRadius:6, textAlign:'center', border: st.rest ? '1px dashed var(--border)' : 'none' }}>
                  <div style={{ fontSize:9, letterSpacing:'0.1em', opacity:0.7 }}>{d}</div>
                  <div className="f-display" style={{ fontSize:18, marginTop:2 }}>{st.done ? '✓' : st.rest ? '—' : (i+19)}</div>
                </div>
              );
            })}
          </div>
        </div>

        {/* PR recente */}
        <div className="card" style={{ padding: 16 }}>
          <div className="label-sm" style={{ marginBottom: 12 }}>ÚLTIMO PR</div>
          <div className="lrow" style={{ padding: 0, border:'none' }}>
            <div style={{ width:40, height:40, borderRadius:'50%', background:'var(--bg-2)', display:'flex', alignItems:'center', justifyContent:'center', color:'var(--accent)' }}>
              <Icon name="trophy" size={20}/>
            </div>
            <div style={{ flex:1 }}>
              <div style={{ fontSize:14, fontWeight:600 }}>Supino Inclinado Halter</div>
              <div style={{ fontSize:12, color:'var(--text-dim)' }}>há 2 dias</div>
            </div>
            <div className="f-display" style={{ fontSize:24, color:'var(--accent)' }}>30kg×8</div>
          </div>
        </div>
      </div>
      <TabBar active="home"/>
    </div>
  );
}

function SemanaMobile() {
  const dias = [
    { dia:"SEG", treino:"PULL A", grupos:"Costas · Bíceps", status:"done", vol:"6.8t" },
    { dia:"TER", treino:"LEGS A", grupos:"Quadríceps · Glúteo", status:"done", vol:"12.4t" },
    { dia:"QUA", treino:"DESCANSO", grupos:"Mobilidade", status:"rest" },
    { dia:"QUI", treino:"PUSH A", grupos:"Peito · Ombro · Tríceps", status:"today", vol:"8.4t" },
    { dia:"SEX", treino:"PULL B", grupos:"Costas · Bíceps", vol:"7.2t" },
    { dia:"SAB", treino:"LEGS B", grupos:"Posterior · Panturrilha", vol:"10.1t" },
    { dia:"DOM", treino:"DESCANSO", grupos:"Folga", status:"rest" },
  ];
  return (
    <div className="mob" data-screen-label="Semana — Mobile">
      <MobStatus/>
      <MobHead over="Ciclo Hipertrofia · Sem 22" title="SUA SEMANA"
               right={<button className="btn ghost" style={{ padding:'8px 10px' }}><Icon name="plus" size={16}/></button>}/>
      <div className="mob-scroll">
        <div className="col gap-3">
          {dias.map((d, i) => (
            <div key={i} className="card" style={{ padding:'16px 18px',
              borderColor: d.status==='today' ? 'var(--accent)' : 'var(--hairline)',
              opacity: d.status==='rest' ? 0.6 : 1 }}>
              <div style={{ display:'flex', alignItems:'center', gap:14 }}>
                <div className="f-display" style={{ fontSize: 20, color: d.status==='today'?'var(--accent)':'var(--text-dim)', width: 36 }}>{d.dia}</div>
                <div style={{ flex:1 }}>
                  <div className="f-display" style={{ fontSize: 30, lineHeight: 1 }}>{d.treino}</div>
                  <div style={{ fontSize:12, color:'var(--text-dim)', marginTop:2 }}>{d.grupos}</div>
                </div>
                {d.status==='done' && <div className="check checked" style={{ width:22, height:22 }}><Icon name="check" size={13} stroke={3}/></div>}
                {d.status==='today' && <button className="btn primary" style={{ padding:'8px 14px' }}><Icon name="play" size={12}/></button>}
                {!d.status && <span className="f-mono" style={{ fontSize:13, color:'var(--text-dim)' }}>{d.vol}</span>}
              </div>
            </div>
          ))}
        </div>
      </div>
      <TabBar active="semana"/>
    </div>
  );
}

function BibliotecaMobile() {
  const ex = [
    { nome:"Supino Reto Barra", grupo:"Peito", equip:"Barra", pr:"100kg×5" },
    { nome:"Supino Inclinado Halter", grupo:"Peito", equip:"Halter", pr:"30kg×8" },
    { nome:"Crucifixo Polia Alta", grupo:"Peito", equip:"Polia", pr:"18kg×12" },
    { nome:"Desenvolvimento Militar", grupo:"Ombro", equip:"Barra", pr:"60kg×5" },
    { nome:"Elevação Lateral", grupo:"Ombro", equip:"Halter", pr:"14kg×12" },
    { nome:"Tríceps Corda", grupo:"Tríceps", equip:"Polia", pr:"32kg×12" },
  ];
  return (
    <div className="mob" data-screen-label="Biblioteca — Mobile">
      <MobStatus/>
      <MobHead over="124 exercícios" title="EXERCÍCIOS"/>
      <div style={{ padding:'0 16px 12px' }}>
        <div style={{ position:'relative' }}>
          <input className="input" placeholder="Buscar..." style={{ paddingLeft: 40 }}/>
          <Icon name="search" size={16} style={{ position:'absolute', left:14, top:14, color:'var(--text-faint)' }}/>
        </div>
        <div style={{ display:'flex', gap:6, overflow:'auto', marginTop:12, paddingBottom:4 }}>
          {['Todos','Peito','Costas','Ombro','Bíceps','Tríceps','Perna'].map((g,i)=>(
            <span key={i} className={"chip" + (i===0?" solid":"")} style={{ whiteSpace:'nowrap' }}>{g}</span>
          ))}
        </div>
      </div>
      <div className="mob-scroll" style={{ paddingTop: 4 }}>
        <div className="col">
          {ex.map((e, i) => (
            <div key={i} className="lrow">
              <div className="ph-img" style={{ width:56, height:56, flexShrink:0 }}/>
              <div style={{ flex:1, minWidth:0 }}>
                <div style={{ fontSize:15, fontWeight:600 }}>{e.nome}</div>
                <div style={{ display:'flex', gap:6, marginTop:5 }}>
                  <span className="chip muscle" style={{ fontSize:9, padding:'2px 8px' }}>{e.grupo}</span>
                  <span className="chip" style={{ fontSize:9, padding:'2px 8px' }}>{e.equip}</span>
                </div>
              </div>
              <div style={{ textAlign:'right' }}>
                <div style={{ fontSize:9, color:'var(--text-faint)', letterSpacing:'0.1em' }}>PR</div>
                <div className="f-mono" style={{ fontSize:13, fontWeight:600, color:'var(--accent)' }}>{e.pr}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
      <TabBar active="biblio"/>
    </div>
  );
}

Object.assign(window, { DashHoje, SemanaMobile, BibliotecaMobile });
