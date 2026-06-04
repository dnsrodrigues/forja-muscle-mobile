/* global React, Icon, MobStatus, TabBar, MobHead */
// Progresso (gráficos) + Perfil + Meus Alunos (Personal)

function ProgressoMobile() {
  const data = [62,65,70,68,72,75,78,82,80,85,88,92];
  const max = Math.max(...data), w = 320, h = 140;
  const pts = data.map((v,i)=>`${(i/(data.length-1))*w},${h-(v/max)*h*0.85}`).join(' ');
  const area = `0,${h} ${pts} ${w},${h}`;
  return (
    <div className="mob" data-screen-label="Progresso — Mobile">
      <MobStatus/>
      <MobHead over="Últimos 90 dias" title="PROGRESSO"/>
      <div style={{ padding:'0 16px 10px' }}>
        <div className="seg">
          <button>7d</button><button>30d</button><button className="on">90d</button><button>1a</button>
        </div>
      </div>
      <div className="mob-scroll" style={{ paddingTop: 6 }}>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:10, marginBottom: 14 }}>
          <div className="kpi"><div className="stat-label">Treinos</div><div className="v" style={{ fontSize:34 }}>38</div><div style={{ fontSize:11, color:'var(--success)' }}>+4 vs ant.</div></div>
          <div className="kpi"><div className="stat-label">Volume</div><div className="v" style={{ fontSize:34 }}>284t</div><div style={{ fontSize:11, color:'var(--success)' }}>+18%</div></div>
          <div className="kpi"><div className="stat-label">PRs novos</div><div className="v" style={{ fontSize:34, color:'var(--accent)' }}>14</div><div style={{ fontSize:11, color:'var(--text-dim)' }}>6 esta sem.</div></div>
          <div className="kpi"><div className="stat-label">Aderência</div><div className="v" style={{ fontSize:34 }}>94%</div><div style={{ fontSize:11, color:'var(--warn)' }}>−2pp</div></div>
        </div>

        {/* Chart card */}
        <div className="card" style={{ padding: 18, marginBottom: 14 }}>
          <div className="label-sm">Supino Inclinado Halter</div>
          <div style={{ display:'flex', alignItems:'baseline', gap:10, marginTop:4 }}>
            <div className="f-display" style={{ fontSize: 48, color:'var(--accent)' }}>30<span className="stat-unit">kg×8</span></div>
            <span style={{ color:'var(--success)', fontSize:12 }}>↗ +6kg / 12sem</span>
          </div>
          <svg viewBox={`0 -10 ${w} ${h+20}`} width="100%" style={{ marginTop: 12, display:'block' }}>
            <defs><linearGradient id="mg" x1="0" x2="0" y1="0" y2="1"><stop offset="0%" stopColor="#d4ff3a" stopOpacity="0.35"/><stop offset="100%" stopColor="#d4ff3a" stopOpacity="0"/></linearGradient></defs>
            <polygon points={area} fill="url(#mg)"/>
            <polyline points={pts} fill="none" stroke="var(--accent)" strokeWidth="2.5"/>
            <circle cx={w} cy={h-(data[data.length-1]/max)*h*0.85} r="5" fill="var(--accent)"/>
          </svg>
        </div>

        {/* Group distribution */}
        <div className="card" style={{ padding: 18 }}>
          <div className="label-sm" style={{ marginBottom: 14 }}>Volume por grupo</div>
          <div className="col gap-3">
            {[{l:"Costas",p:22,a:"62t",hi:1},{l:"Peito",p:18,a:"51t",hi:1},{l:"Perna",p:16,a:"45t",hi:1},{l:"Ombro",p:14,a:"40t"},{l:"Tríceps",p:10,a:"28t"}].map((g,i)=>(
              <div key={i}>
                <div style={{ display:'flex', justifyContent:'space-between', fontSize:13, marginBottom:5 }}><span>{g.l}</span><span className="f-mono" style={{ color:'var(--text-dim)' }}>{g.a} · {g.p}%</span></div>
                <div className="bar"><span style={{ width:`${(g.p/22)*100}%`, background: g.hi?'var(--accent)':'var(--bg-4)' }}/></div>
              </div>
            ))}
          </div>
        </div>
      </div>
      <TabBar active="perfil"/>
    </div>
  );
}

function PerfilMobile() {
  return (
    <div className="mob" data-screen-label="Perfil — Mobile">
      <MobStatus/>
      <div className="mob-scroll" style={{ padding: 0 }}>
        {/* Header */}
        <div style={{ position:'relative' }}>
          <div className="ph-img" style={{ height: 120, borderRadius: 0, border:'none' }}/>
          <div style={{ display:'flex', flexDirection:'column', alignItems:'center', marginTop: -50, padding:'0 20px' }}>
            <div style={{ width:100, height:100, borderRadius: 20, background:'linear-gradient(135deg,#1a1b1c,#050506)', border:'4px solid var(--bg-0)', display:'flex', alignItems:'center', justifyContent:'center', fontFamily:'var(--f-display)', fontSize:50, lineHeight:1, color:'var(--accent)' }}>LM</div>
            <h1 className="f-display" style={{ fontSize: 36, lineHeight: 1.08, margin:'14px 0 10px' }}>LUCAS MENDES</h1>
            <div style={{ display:'flex', gap:6 }}>
              <span className="chip">Hipertrofia</span>
              <span className="chip muscle">Personal: Bruno R.</span>
            </div>
          </div>
        </div>

        <div style={{ padding:'20px 16px' }}>
          <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:10, marginBottom: 18 }}>
            <div className="kpi" style={{ padding:14, textAlign:'center' }}><div className="stat-label" style={{ fontSize:9 }}>Treinos</div><div className="v" style={{ fontSize:28 }}>284</div></div>
            <div className="kpi" style={{ padding:14, textAlign:'center' }}><div className="stat-label" style={{ fontSize:9 }}>Streak</div><div className="v" style={{ fontSize:28, color:'var(--accent)' }}>17d</div></div>
            <div className="kpi" style={{ padding:14, textAlign:'center' }}><div className="stat-label" style={{ fontSize:9 }}>PRs</div><div className="v" style={{ fontSize:28, color:'var(--accent)' }}>38</div></div>
          </div>

          <div className="card" style={{ padding: 6 }}>
            {[
              { i:"user", l:"Dados pessoais" },
              { i:"chart", l:"Medidas corporais" },
              { i:"bell", l:"Notificações", badge:"3" },
              { i:"settings", l:"Preferências e unidades" },
              { i:"trophy", l:"Conquistas" },
            ].map((row, i, arr) => (
              <div key={i} style={{ display:'flex', alignItems:'center', gap:14, padding:'15px 12px', borderBottom: i<arr.length-1?'1px solid var(--hairline)':'none' }}>
                <div style={{ color:'var(--text-dim)' }}><Icon name={row.i} size={20}/></div>
                <span style={{ flex:1, fontSize:15, fontWeight:500 }}>{row.l}</span>
                {row.badge && <span className="chip solid" style={{ padding:'2px 8px', fontSize:10 }}>{row.badge}</span>}
                <Icon name="arrow" size={16} stroke={1.5}/>
              </div>
            ))}
          </div>

          <button className="btn ghost cta" style={{ marginTop: 16, color:'var(--danger)', borderColor:'rgba(255,61,85,0.3)' }}>
            <Icon name="logout" size={16}/> Sair da conta
          </button>
        </div>
      </div>
      <TabBar active="perfil"/>
    </div>
  );
}

// Personal trainer: lista de alunos
function MeusAlunos() {
  const alunos = [
    { n:"João Pereira", ini:"JP", obj:"Hipertrofia", hoje:"PUSH A", status:"treinou", prog:82 },
    { n:"Marina Costa", ini:"MC", obj:"Cutting", hoje:"LEGS", status:"agora", prog:45 },
    { n:"Rafael Dias", ini:"RD", obj:"Força", hoje:"Descanso", status:"folga", prog:100 },
    { n:"Ana Beatriz", ini:"AB", obj:"Resistência", hoje:"PULL B", status:"pendente", prog:0 },
    { n:"Carlos Nunes", ini:"CN", obj:"Hipertrofia", hoje:"UPPER", status:"treinou", prog:90 },
  ];
  const stColor = { treinou:'var(--success)', agora:'var(--accent)', folga:'var(--text-faint)', pendente:'var(--warn)' };
  const stLabel = { treinou:'Concluiu', agora:'Treinando', folga:'Descanso', pendente:'Pendente' };
  return (
    <div className="mob" data-screen-label="Meus Alunos (Personal) — Mobile">
      <MobStatus/>
      <MobHead over="Personal · Bruno R." title="MEUS ALUNOS"
               right={<button className="btn ghost" style={{ padding:'8px 10px' }}><Icon name="plus" size={16}/></button>}/>
      <div style={{ padding:'0 16px 12px', display:'flex', gap:10 }}>
        <div className="kpi" style={{ flex:1, padding:14 }}><div className="stat-label" style={{ fontSize:9 }}>Ativos</div><div className="v" style={{ fontSize:30 }}>12</div></div>
        <div className="kpi" style={{ flex:1, padding:14 }}><div className="stat-label" style={{ fontSize:9 }}>Treinaram hoje</div><div className="v" style={{ fontSize:30, color:'var(--success)' }}>8</div></div>
        <div className="kpi" style={{ flex:1, padding:14 }}><div className="stat-label" style={{ fontSize:9 }}>Pendências</div><div className="v" style={{ fontSize:30, color:'var(--warn)' }}>2</div></div>
      </div>
      <div className="mob-scroll" style={{ paddingTop: 4 }}>
        <div className="col">
          {alunos.map((a, i) => (
            <div key={i} className="lrow">
              <div className="nav-avatar" style={{ width:46, height:46, fontSize:18, borderRadius:12 }}>{a.ini}</div>
              <div style={{ flex:1, minWidth:0 }}>
                <div style={{ fontSize:15, fontWeight:600 }}>{a.n}</div>
                <div style={{ fontSize:12, color:'var(--text-dim)' }}>{a.obj} · hoje: {a.hoje}</div>
              </div>
              <div style={{ display:'flex', flexDirection:'column', alignItems:'flex-end', gap:5 }}>
                <span style={{ fontSize:10, fontWeight:700, letterSpacing:'0.06em', textTransform:'uppercase', color: stColor[a.status] }}>{stLabel[a.status]}</span>
                <span style={{ width:8, height:8, borderRadius:99, background: stColor[a.status] }}/>
              </div>
            </div>
          ))}
        </div>
      </div>
      <TabBar active="home"/>
    </div>
  );
}

Object.assign(window, { ProgressoMobile, PerfilMobile, MeusAlunos });
