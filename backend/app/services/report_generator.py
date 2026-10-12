"""
PDF Report Generator using ReportLab.
"""
import os
import io
import logging
from datetime import datetime
from typing import List, Optional

from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import cm
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    HRFlowable, PageBreak,
)
from reportlab.graphics.shapes import Drawing, Rect, String
from reportlab.graphics.charts.barcharts import VerticalBarChart
from reportlab.graphics import renderPDF

from app.models.schemas import RecommendationResponse, ScenarioResponse

logger = logging.getLogger(__name__)

# ─── Colour Palette ────────────────────────────────────────────
GREEN_DARK = colors.HexColor("#166534")
GREEN_MED = colors.HexColor("#15803d")
GREEN_LIGHT = colors.HexColor("#dcfce7")
GREEN_ACCENT = colors.HexColor("#22c55e")
WHITE = colors.white
SLATE = colors.HexColor("#64748b")
NEAR_BLACK = colors.HexColor("#0f172a")
BORDER = colors.HexColor("#e2e8f0")
YELLOW = colors.HexColor("#fef9c3")


def _styles():
    base = getSampleStyleSheet()
    custom = {
        "Title": ParagraphStyle("Title", fontName="Helvetica-Bold", fontSize=26,
                                 textColor=GREEN_DARK, alignment=TA_CENTER, spaceAfter=6),
        "Subtitle": ParagraphStyle("Subtitle", fontName="Helvetica", fontSize=12,
                                    textColor=SLATE, alignment=TA_CENTER, spaceAfter=4),
        "H2": ParagraphStyle("H2", fontName="Helvetica-Bold", fontSize=14,
                               textColor=GREEN_DARK, spaceBefore=14, spaceAfter=6),
        "H3": ParagraphStyle("H3", fontName="Helvetica-Bold", fontSize=11,
                               textColor=NEAR_BLACK, spaceBefore=8, spaceAfter=4),
        "Body": ParagraphStyle("Body", fontName="Helvetica", fontSize=10,
                                textColor=NEAR_BLACK, spaceAfter=4, leading=14),
        "Caption": ParagraphStyle("Caption", fontName="Helvetica-Oblique", fontSize=9,
                                   textColor=SLATE, spaceAfter=2),
        "SmallRight": ParagraphStyle("SmallRight", fontName="Helvetica", fontSize=8,
                                      textColor=SLATE, alignment=TA_RIGHT),
    }
    return custom


def _header(canvas, doc, district_name, year):
    canvas.saveState()
    w, h = A4
    canvas.setFillColor(GREEN_DARK)
    canvas.rect(0, h - 2.2 * cm, w, 2.2 * cm, fill=1, stroke=0)
    canvas.setFillColor(WHITE)
    canvas.setFont("Helvetica-Bold", 14)
    canvas.drawString(1.5 * cm, h - 1.3 * cm, "AgriCAST")
    canvas.setFont("Helvetica", 10)
    canvas.drawString(1.5 * cm, h - 1.75 * cm, "AI-Powered Crop Recommendation System")
    canvas.setFont("Helvetica", 9)
    canvas.drawRightString(w - 1.5 * cm, h - 1.3 * cm, f"{district_name} | {year}")
    canvas.drawRightString(w - 1.5 * cm, h - 1.75 * cm,
                           f"Generated: {datetime.now().strftime('%d %b %Y %H:%M')}")
    # Footer
    canvas.setFillColor(BORDER)
    canvas.rect(0, 0, w, 0.8 * cm, fill=1, stroke=0)
    canvas.setFillColor(SLATE)
    canvas.setFont("Helvetica", 8)
    canvas.drawString(1.5 * cm, 0.25 * cm, "AgriCAST v1.0  |  Confidential — For Agricultural Decision Support Only")
    canvas.drawRightString(w - 1.5 * cm, 0.25 * cm, f"Page {doc.page}")
    canvas.restoreState()


def generate_report(
    recommendation: RecommendationResponse,
    scenario: Optional[ScenarioResponse] = None,
    output_dir: str = "reports",
) -> str:
    os.makedirs(output_dir, exist_ok=True)
    filename = f"AgriCAST_{recommendation.district_name}_{recommendation.year}.pdf"
    filepath = os.path.join(output_dir, filename)

    S = _styles()
    doc = SimpleDocTemplate(
        filepath, pagesize=A4,
        leftMargin=1.8 * cm, rightMargin=1.8 * cm,
        topMargin=3.0 * cm, bottomMargin=1.5 * cm,
    )

    def make_page(canvas, doc):
        _header(canvas, doc, recommendation.district_name, recommendation.year)

    elements = []

    # ── Cover ──────────────────────────────────────────────────
    elements.append(Spacer(1, 0.8 * cm))
    elements.append(Paragraph("Crop Recommendation Report", S["Title"]))
    elements.append(Paragraph(
        f"{recommendation.district_name}, {recommendation.state_name}  •  {recommendation.year}",
        S["Subtitle"],
    ))
    elements.append(HRFlowable(width="100%", thickness=1, color=GREEN_LIGHT, spaceAfter=12))

    # ── Summary Box ────────────────────────────────────────────
    top_crop = recommendation.top_crop
    top_conf = recommendation.top_confidence
    summary_data = [
        ["Top Recommended Crop", top_crop, f"Confidence: {top_conf:.1f}%"],
        ["District", recommendation.district_name, recommendation.state_name],
        ["Assessment Year", str(recommendation.year), f"Crops Evaluated: {len(recommendation.rankings)}"],
    ]
    summary_table = Table(summary_data, colWidths=[5 * cm, 7 * cm, 5 * cm])
    summary_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), GREEN_DARK),
        ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, 0), 12),
        ("BACKGROUND", (0, 1), (-1, -1), GREEN_LIGHT),
        ("FONTNAME", (0, 1), (0, -1), "Helvetica-Bold"),
        ("FONTSIZE", (0, 1), (-1, -1), 10),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [GREEN_LIGHT, WHITE]),
        ("GRID", (0, 0), (-1, -1), 0.5, BORDER),
        ("PADDING", (0, 0), (-1, -1), 8),
        ("ALIGN", (2, 0), (2, -1), "CENTER"),
    ]))
    elements.append(summary_table)
    elements.append(Spacer(1, 0.4 * cm))

    # ── Recommendation Explanation ─────────────────────────────
    elements.append(Paragraph("Recommendation Explanation", S["H2"]))
    elements.append(Paragraph(recommendation.explanation, S["Body"]))
    elements.append(Spacer(1, 0.3 * cm))

    # ── Full Crop Rankings ─────────────────────────────────────
    elements.append(Paragraph("Full Crop Ranking", S["H2"]))
    rank_header = ["Rank", "Crop", "Confidence (%)", "Prev. Yield (kg/ha)", "Hist. Mean (kg/ha)", "Area Share (%)"]
    rank_data = [rank_header]
    for r in recommendation.rankings:
        rank_data.append([
            str(r.rank),
            r.crop,
            f"{r.confidence:.1f}%",
            f"{r.yield_lag1:.0f}" if r.yield_lag1 else "—",
            f"{r.yield_hist_mean:.0f}" if r.yield_hist_mean else "—",
            f"{(r.area_share or 0) * 100:.1f}%",
        ])

    rank_table = Table(rank_data, colWidths=[1.5 * cm, 4 * cm, 3.2 * cm, 3.5 * cm, 3.5 * cm, 3 * cm])
    ts = [
        ("BACKGROUND", (0, 0), (-1, 0), GREEN_DARK),
        ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
        ("ALIGN", (1, 1), (1, -1), "LEFT"),
        ("GRID", (0, 0), (-1, -1), 0.4, BORDER),
        ("PADDING", (0, 0), (-1, -1), 6),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [WHITE, GREEN_LIGHT]),
    ]
    # Highlight top crop
    if len(rank_data) > 1:
        ts += [
            ("BACKGROUND", (0, 1), (-1, 1), colors.HexColor("#bbf7d0")),
            ("FONTNAME", (0, 1), (-1, 1), "Helvetica-Bold"),
        ]
    rank_table.setStyle(TableStyle(ts))
    elements.append(rank_table)
    elements.append(Spacer(1, 0.4 * cm))

    # ── Feature Influences ─────────────────────────────────────
    elements.append(Paragraph("Key Influencing Factors", S["H2"]))
    inf_header = ["Factor", "Influence Direction", "Magnitude"]
    inf_data = [inf_header]
    dir_map = {"positive": "↑ Favourable", "negative": "↓ Unfavourable", "neutral": "→ Neutral"}
    for inf in recommendation.feature_influences:
        inf_data.append([
            inf.display_name,
            dir_map.get(inf.direction, inf.direction),
            inf.magnitude.capitalize(),
        ])
    inf_table = Table(inf_data, colWidths=[8 * cm, 5 * cm, 4.5 * cm])
    inf_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), GREEN_MED),
        ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
        ("ALIGN", (1, 0), (-1, -1), "CENTER"),
        ("ALIGN", (0, 1), (0, -1), "LEFT"),
        ("GRID", (0, 0), (-1, -1), 0.4, BORDER),
        ("PADDING", (0, 0), (-1, -1), 6),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [WHITE, GREEN_LIGHT]),
    ]))
    elements.append(inf_table)

    # ── Scenario Section ───────────────────────────────────────
    if scenario:
        elements.append(PageBreak())
        elements.append(Paragraph("Scenario Analysis", S["H2"]))

        change_text = "⚠ Recommendation Changed" if scenario.recommendation_changed else "✓ Recommendation Unchanged"
        change_color = colors.HexColor("#fef3c7") if scenario.recommendation_changed else GREEN_LIGHT
        chg_data = [
            ["Baseline Crop", "Scenario Crop", "Status"],
            [scenario.baseline_top, scenario.scenario_top, change_text],
        ]
        chg_table = Table(chg_data, colWidths=[5.5 * cm, 5.5 * cm, 6.5 * cm])
        chg_table.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), GREEN_DARK),
            ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
            ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("FONTSIZE", (0, 0), (-1, -1), 10),
            ("BACKGROUND", (0, 1), (-1, 1), change_color),
            ("FONTNAME", (0, 1), (-1, 1), "Helvetica-Bold"),
            ("ALIGN", (0, 0), (-1, -1), "CENTER"),
            ("GRID", (0, 0), (-1, -1), 0.5, BORDER),
            ("PADDING", (0, 0), (-1, -1), 8),
        ]))
        elements.append(chg_table)
        elements.append(Spacer(1, 0.3 * cm))
        elements.append(Paragraph("Scenario Analysis Explanation", S["H3"]))
        elements.append(Paragraph(scenario.explanation, S["Body"]))

        # Scenario params table
        params = scenario.scenario_params
        param_data = [
            ["Parameter", "Value Applied"],
            ["Rainfall Change", f"{params.get('rainfall_change', 0):+.0f}%"],
            ["Temperature Change", f"{params.get('temperature_change', 0):+.1f}°C"],
            ["Irrigation Change", f"{params.get('irrigation_change', 0):+.0f}%"],
            ["Fertiliser Change", f"{params.get('fertilizer_change', 0):+.0f}%"],
        ]
        p_table = Table(param_data, colWidths=[8 * cm, 9.5 * cm])
        p_table.setStyle(TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), GREEN_MED),
            ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
            ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("FONTSIZE", (0, 0), (-1, -1), 9),
            ("ALIGN", (1, 0), (1, -1), "CENTER"),
            ("GRID", (0, 0), (-1, -1), 0.4, BORDER),
            ("PADDING", (0, 0), (-1, -1), 6),
            ("ROWBACKGROUNDS", (0, 1), (-1, -1), [WHITE, GREEN_LIGHT]),
        ]))
        elements.append(Spacer(1, 0.3 * cm))
        elements.append(Paragraph("Scenario Parameters", S["H3"]))
        elements.append(p_table)

    # ── Climate Summary ────────────────────────────────────────
    elements.append(Spacer(1, 0.5 * cm))
    elements.append(Paragraph("Climate Summary", S["H2"]))
    cs = recommendation.climate_summary
    clim_data = [
        ["Metric", "Value"],
        ["Annual Precipitation", f"{cs.get('total_annual_precip_mm', 0):.0f} mm"],
        ["Monsoon Season Precipitation", f"{cs.get('monsoon_precip_mm', 0):.0f} mm"],
        ["Average Maximum Temperature", f"{cs.get('avg_max_temp_c', 0):.1f} °C"],
        ["Average Minimum Temperature", f"{cs.get('avg_min_temp_c', 0):.1f} °C"],
        ["Irrigation Coverage Ratio", f"{cs.get('irr_ratio', 0):.2%}"],
    ]
    c_table = Table(clim_data, colWidths=[9 * cm, 8.5 * cm])
    c_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), GREEN_MED),
        ("TEXTCOLOR", (0, 0), (-1, 0), WHITE),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
        ("GRID", (0, 0), (-1, -1), 0.4, BORDER),
        ("PADDING", (0, 0), (-1, -1), 6),
        ("ROWBACKGROUNDS", (0, 1), (-1, -1), [WHITE, GREEN_LIGHT]),
    ]))
    elements.append(c_table)
    elements.append(Spacer(1, 1 * cm))

    # ── Disclaimer ────────────────────────────────────────────
    elements.append(HRFlowable(width="100%", thickness=0.5, color=BORDER))
    elements.append(Spacer(1, 0.2 * cm))
    elements.append(Paragraph(
        "This report was generated by the AgriCAST AI Crop Recommendation System using a "
        "LambdaMART Learning-to-Rank model trained on historical agricultural and climate data. "
        "Recommendations are decision-support tools and should be verified with local agronomists "
        "before operational use. AgriCAST v1.0",
        S["Caption"],
    ))

    doc.build(elements, onFirstPage=make_page, onLaterPages=make_page)
    logger.info(f"Report saved: {filepath}")
    return filepath
