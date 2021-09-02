import PropTypes from 'prop-types';
import { useEffect, useState } from 'react';
import availability from '../index.js';
import Spinner from './spinner.jsx';

const IllLink = ({holding}) => {
    const [hasData, setHasData] = useState(false);
    const [showSpinner, setShowSpinner] = useState(true);
    const [url, setUrl] = useState('#');

    useEffect(() => {
        createIllUrl();
    }, []);

    const createIllUrl = () => {
        let illUrl = "https://psu-illiad-oclc-org.ezaccess.libraries.psu.edu/illiad/";
        const catkey = holding.catkey;
        const callNumber = encodeURIComponent(holding.callNumber);
        const linkType = encodeURIComponent(illLinkType());
        const itemLocation = encodeURIComponent(holding.locationID);

        $.get(`/catalog/${catkey}/raw.json`).then((data) => {
            if (Object.keys(data).length > 0) {
                setHasData(true);

                const title = encodeURIComponent(data.title_245ab_tsim);
                const author = encodeURIComponent(data.author_tsim ? data.author_tsim : "");
                const pubDate = data.pub_date_illiad_ssm ? data.pub_date_illiad_ssm : "";

                illUrl += "upm/illiad.dll/OpenURL?Action=10";
                if (linkType === "archival-thesis") {
                    illUrl += "&Form=20&Genre=GenericRequestThesisDigitization";
                }
                else {
                    const ISBN = data.isbn_ssm ? data.isbn_ssm : "";
                    illUrl += `&Form=30&isbn=${ISBN}`;
                }
                if (linkType === "reserves-scan") {
                    illUrl += `&Genre=GenericRequestReserves&location=${itemLocation}`;
                }
                if (linkType === "news-microform-scan") {
                    illUrl += `&Genre=GenericRequestMicroScan&location=${itemLocation}`;
                }
                illUrl += `&title=${title}&callno=${callNumber}&rfr_id=info%3Asid%2Fcatalog.libraries.psu.edu`;
                if (author) {
                    illUrl += `&aulast=${author}`;
                }
                if (pubDate) {
                    illUrl += `&date=${pubDate}`;
                }
            }

            setShowSpinner(false);
            setUrl(illUrl);
        }).catch(() => {
            setShowSpinner(false);
            setUrl(illUrl);
        });
    };

    const illLinkType = () => {
        if (availability.isReserves(holding)) return "reserves-scan";
        if (availability.isMicroform(holding)) return "news-microform-scan";
        if (availability.isArchivalThesis(holding)) return "archival-thesis";

        return "request-via-ill";
    };

    const label = () => {
        if (!hasData) {
            return "Use ILLiad to request this item";
        }

        if (availability.isMicroform(holding) || availability.isArchivalThesis(holding)) {
            return "Request Scan - Penn State Users";
        }

        return availability.illiadLocations[holding.locationID];
    };

    const linkTarget = () => {
        return hasData ? null : "_blank";
    };

    return (
        <a href={url} target={linkTarget()}>
            <Spinner isVisible={showSpinner} />

            {label()}
        </a>
    );
};

// eslint-react: defines valid prop types passed to this component
IllLink.propTypes = {
    holding: PropTypes.object
};

export default IllLink;
